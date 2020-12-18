//
//  CocoaAsyncService.h
//  GacOSX
//
//  Created by Robert Bu on 12/8/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_COCOA_ASYNC_SERVICE__
#define __GAC_OSX_COCOA_ASYNC_SERVICE__

#include "GacUI.h"

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            // todo
            // rewrite this guy with GCD & NSOperation & NSOperationQueue
            
            class CocoaAsyncService: public INativeAsyncService
            {
            protected:
                struct TaskItem
                {
                    Semaphore*              semaphore;
                    Func<void()>            proc;
                    
                    TaskItem();
                    TaskItem(Semaphore* _semaphore, const Func<void()>& _proc);
                    ~TaskItem();
                };
                
                class DelayItem: public Object, public INativeDelay
                {
                public:
                    DelayItem(CocoaAsyncService* _service, const Func<void()>& _proc, bool _executeInMainThread, vint milliseconds);
                    ~DelayItem();
                    
                    CocoaAsyncService*      service;
                    Func<void()>            proc;
                    ExecuteStatus           status;
                    DateTime                executeTime;
                    bool                    executeInMainThread;
                    
                    ExecuteStatus           GetStatus() override;
                    bool                    Delay(vint milliseconds) override;
                    bool                    Cancel() override;
                };
                
                collections::List<TaskItem>				taskItems;
                collections::List<Ptr<DelayItem>>		delayItems;
                SpinLock								taskListLock;
                vint                                    mainThreadId;
                
            public:
                CocoaAsyncService();
                ~CocoaAsyncService();
                
                void                ExecuteAsyncTasks();
                bool                IsInMainThread(INativeWindow* window)override;
                void                InvokeAsync(const Func<void()>& proc)override;
                void                InvokeInMainThread(INativeWindow* window, const Func<void()>& proc)override;
                bool                InvokeInMainThreadAndWait(INativeWindow* window, const Func<void()>& proc, vint milliseconds)override;
                Ptr<INativeDelay>   DelayExecute(const Func<void()>& proc, vint milliseconds)override;
                Ptr<INativeDelay>   DelayExecuteInMainThread(const Func<void()>& proc, vint milliseconds)override;
            };
            
        }
        
    }
    
}


#endif
