using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace NestleDatabase
{
    public class WordTokenizer
    {
        class WordRoot
        {
            public int score = -1;
            public Dictionary<char, WordRoot> nodes = null;

            public void Add(string word, int wordScore)
            {
                if (word.Length > 0)
                {
                    char first = word[0];
                    string next = word.Substring(1);

                    WordRoot root = null;
                    if (this.nodes == null)
                    {
                        this.nodes = new Dictionary<char, WordRoot>();
                    }
                    if (!this.nodes.TryGetValue(first, out root))
                    {
                        root = new WordRoot();
                        this.nodes.Add(first, root);
                    }

                    root.Add(next, wordScore);
                }
                else
                {
                    this.score = wordScore;
                }
            }

            public void Search(string input, int index, List<Tuple<string, int>> candidates)
            {
                if (this.score != -1)
                {
                    candidates.Add(Tuple.Create(input.Substring(0, index), this.score));
                }
                if (index < input.Length && this.nodes != null)
                {
                    char first = input[index];
                    WordRoot root = null;
                    if (this.nodes.TryGetValue(first, out root))
                    {
                        root.Search(input, index + 1, candidates);
                    }
                }
            }
        }

        private WordRoot libraryRoot = new WordRoot();

        public WordTokenizer()
        {
            List<Tuple<string, int>> result = new List<Tuple<string, int>>();
            using (StreamReader reader = new StreamReader(typeof(WordTokenizer).Assembly.GetManifestResourceStream("NestleDatabase.Words.txt")))
            {
                while (!reader.EndOfStream)
                {
                    string line = reader.ReadLine();
                    string[] fragments = line.Split('|');
                    int score = int.Parse(fragments[2]);
                    if (score > 0)
                    {
                        this.libraryRoot.Add(fragments[0], score);
                    }
                }
            }
        }

        class Token
        {
            public Token previous;
            public string word;
            public int score;
            public int totalScore;
        }

        class TokenSelector
        {
            private Token result;
            private int wordCount;

            public void AddChoice(Token token)
            {
                int count = 0;
                Token current = token;
                while (current != null)
                {
                    count++;
                    current = current.previous;
                }

                if (result == null || result.totalScore < token.totalScore || (result.totalScore == token.totalScore && wordCount > count))
                {
                    result = token;
                    wordCount = count;
                }
            }

            public string[] Result
            {
                get
                {
                    List<string> tokens = new List<string>();
                    Token token = result;
                    while (token != null)
                    {
                        tokens.Add(token.word);
                        token = token.previous;
                    }
                    tokens.Reverse();
                    return tokens.ToArray();
                }
            }
        }

        void TokenizeInternal(string input, Token previous, TokenSelector tokenSelector)
        {
            if (input.Length == 0)
            {
                tokenSelector.AddChoice(previous);
            }
            else
            {
                List<Tuple<string, int>> candidates = new List<Tuple<string, int>>();
                this.libraryRoot.Search(input, 0, candidates);

                if (candidates.Count > 0)
                {
                    foreach (var candidate in candidates)
                    {
                        Token token = new Token();
                        token.word = candidate.Item1;
                        token.score = candidate.Item2;
                        token.previous = previous;
                        token.totalScore = previous == null ? token.score : token.score + previous.score;
                        TokenizeInternal(input.Substring(token.word.Length), token, tokenSelector);
                    }
                }
                else
                {
                    Token token = new Token();
                    token.word = input[0].ToString();
                    token.score = 0;
                    token.previous = previous;
                    token.totalScore = previous == null ? 0 : previous.score;
                    TokenizeInternal(input.Substring(token.word.Length), token, tokenSelector);
                }
            }
        }

        private string[] TokenizeInternal(string input)
        {
            TokenSelector tc = new TokenSelector();
            TokenizeInternal(input, null, tc);
            return tc.Result;
        }

        private static WordTokenizer tokenizerInstance = new WordTokenizer();

        private static bool IsDiscardable(char c)
        {
            uint i = (uint)c;
            return 0x3000 <= i && i <= 0x303F
                || 0xFF01 <= i && i <= 0xFF0F
                || 0xFF01 <= i && i <= 0xFF0F
                || 0xFF1A <= i && i <= 0xFF20
                || 0xFF38 <= i && i <= 0xFF40
                || 0xFF58 <= i && i <= 0xFF5E
                ;
        }

        private static bool IsAscii(char c)
        {
            return (uint)c < 128;
        }

        private static bool IsLetter(char c)
        {
            return 'A' <= c && c <= 'Z' || 'a' <= c && c <= 'z';
        }

        private static string[] Split(string input, Predicate<char> classifier)
        {
            List<int> fragments = new List<int>();
            {
                bool lastClass = false;
                for (int i = 0; i < input.Length; i++)
                {
                    bool charClass = classifier(input[i]);
                    if (i == 0 || charClass != lastClass)
                    {
                        fragments.Add(i);
                        lastClass = charClass;
                    }
                }
                fragments.Add(input.Length);
            }

            return Enumerable
                .Range(0, fragments.Count - 1)
                .Select(i => input.Substring(fragments[i], fragments[i + 1] - fragments[i]))
                .ToArray();
        }

        public static IEnumerable<string> Tokenize(string input)
        {
            string[] fragments = Split(input, IsAscii);
            foreach (var fragment in fragments)
            {
                if (IsAscii(fragment[0]))
                {
                    string[] words = Split(fragment, IsLetter)
                        .Where(f => IsLetter(f[0]))
                        .ToArray();
                    foreach (var word in words)
                    {
                        yield return word;
                    }
                }
                else
                {
                    string[] words = Split(fragment, IsDiscardable)
                        .Where(f => !IsDiscardable(f[0]))
                        .ToArray();
                    foreach (var word in words)
                    {
                        foreach (var token in tokenizerInstance.TokenizeInternal(word))
                        {
                            yield return token;
                        }
                    }
                }
            }
        }
    }
}
