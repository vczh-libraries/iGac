using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Reflection;

namespace AzureStorageFacadeLibrary
{
    class FakeAsyncResult : IAsyncResult
    {
        private object asyncState;

        public FakeAsyncResult(object state)
        {
            this.asyncState = state;
        }

        public object AsyncState
        {
            get
            {
                return this.asyncState;
            }
        }

        public WaitHandle AsyncWaitHandle
        {
            get
            {
                return (WaitHandle)typeof(WaitHandle)
                    .GetField("InvalidHandle", BindingFlags.NonPublic | BindingFlags.Static)
                    .GetValue(null);
            }
        }

        public bool CompletedSynchronously
        {
            get
            {
                return true;
            }
        }

        public bool IsCompleted
        {
            get
            {
                return true;
            }
        }
    }
}
