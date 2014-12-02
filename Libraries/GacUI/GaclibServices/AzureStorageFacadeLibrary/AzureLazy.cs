using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace AzureStorageFacadeLibrary
{
    public class AzureLazy
    {
        public Action SyncAction { get; private set; }
        public Func<AsyncCallback, object, IAsyncResult> AsyncBegin { get; private set; }
        public Action<IAsyncResult> AsyncEnd { get; private set; }

        public AzureLazy(Action syncAction)
        {
            this.SyncAction = syncAction;
            this.AsyncBegin = (ac, st) =>
            {
                var ar = new FakeAsyncResult(st);
                ac(ar);
                return ar;
            };
            this.AsyncEnd = ar => syncAction();
        }

        public AzureLazy(Action syncAction, Func<AsyncCallback, object, IAsyncResult> asyncBegin, Action<IAsyncResult> asyncEnd)
        {
            this.SyncAction = syncAction;
            this.AsyncBegin = asyncBegin;
            this.AsyncEnd = asyncEnd;
        }

        public void Sync()
        {
            this.SyncAction();
        }

        public void Async(Action continuation = null)
        {
            this.AsyncBegin(ar =>
            {
                this.AsyncEnd(ar);
                if (continuation != null)
                {
                    continuation();
                }
            }, null);
        }
    }

    public class AzureLazy<T>
    {
        public Func<T> SyncAction { get; private set; }
        public Func<AsyncCallback, object, IAsyncResult> AsyncBegin { get; private set; }
        public Func<IAsyncResult, T> AsyncEnd { get; private set; }

        public AzureLazy(Func<T> syncAction)
        {
            this.SyncAction = syncAction;
            this.AsyncBegin = (ac, st) =>
            {
                var ar = new FakeAsyncResult(st);
                ac(ar);
                return ar;
            };
            this.AsyncEnd = ar => syncAction();
        }

        public AzureLazy(Func<T> syncAction, Func<AsyncCallback, object, IAsyncResult> asyncBegin, Func<IAsyncResult, T> asyncEnd)
        {
            this.SyncAction = syncAction;
            this.AsyncBegin = asyncBegin;
            this.AsyncEnd = asyncEnd;
        }

        public T Sync()
        {
            return this.SyncAction();
        }

        public void Async(Action<T> continuation = null)
        {
            this.AsyncBegin(ar =>
            {
                T result = this.AsyncEnd(ar);
                if (continuation != null)
                {
                    continuation(result);
                }
            }, null);
        }
    }
}
