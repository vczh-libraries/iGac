//
//  CocoaAsyncService.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/8/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaAsyncService.h"

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            using namespace collections;
            
            CocoaAsyncService::TaskItem::TaskItem():
                semaphore(0)
            {
                
            }
            
            CocoaAsyncService::TaskItem::TaskItem(Semaphore* _semaphore, const Func<void()>& _proc):
                semaphore(_semaphore),
                proc(_proc)
            {
                
            }
            
            CocoaAsyncService::TaskItem::~TaskItem()
            {
                
            }
            
            CocoaAsyncService::DelayItem::DelayItem(CocoaAsyncService* _service, const Func<void()>& _proc, bool _executeInMainThread, vint milliseconds):
            service(_service),
            proc(_proc),
            status(INativeDelay::Pending),
            executeTime(DateTime::LocalTime().Forward(milliseconds)),
            executeInMainThread(_executeInMainThread)
            {
                
            }
            
            CocoaAsyncService::DelayItem::~DelayItem()
            {
                
            }
            
            INativeDelay::ExecuteStatus CocoaAsyncService::DelayItem::GetStatus()
            {
                return status;
            }
            
            bool CocoaAsyncService::DelayItem::Delay(vint milliseconds)
            {
                SPIN_LOCK(service->taskListLock)
                {
                    if(status==INativeDelay::Pending)
                    {
                        executeTime=DateTime::LocalTime().Forward(milliseconds);
                        return true;
                    }
                }
                return false;
            }
            
            bool CocoaAsyncService::DelayItem::Cancel()
            {
                SPIN_LOCK(service->taskListLock)
                {
                    if(status==INativeDelay::Pending)
                    {
                        if(service->delayItems.Remove(this))
                        {
                            status=INativeDelay::Canceled;
                            return true;
                        }
                    }
                }
                return false;
            }

            CocoaAsyncService::CocoaAsyncService():
                mainThreadId(Thread::GetCurrentThreadId())
            {
                
            }
            
            CocoaAsyncService::~CocoaAsyncService()
            {
                
            }
            
            void CocoaAsyncService::ExecuteAsyncTasks()
            {
                DateTime now = DateTime::LocalTime();
                Array<TaskItem> items;
                List<Ptr<DelayItem>> executableDelayItems;
                
                SPIN_LOCK(taskListLock)
                {
                    CopyFrom(items, taskItems);
                    taskItems.RemoveRange(0, items.Count());
                    for(vint i = delayItems.Count()-1;i>=0;i--)
                    {
                        Ptr<DelayItem> item = delayItems[i];
                        if(now.filetime >= item->executeTime.filetime)
                        {
                            item->status = INativeDelay::Executing;
                            executableDelayItems.Add(item);
                            delayItems.RemoveAt(i);
                        }
                    }
                }
                
                FOREACH(TaskItem, item, items)
                {
                    item.proc();
                    if(item.semaphore)
                    {
                        item.semaphore->Release();
                    }
                }
                
                FOREACH(Ptr<DelayItem>, item, executableDelayItems)
                {
                    if(item->executeInMainThread)
                    {
                        item->proc();
                        item->status=INativeDelay::Executed;
                    }
                    else
                    {
                        InvokeAsync([=]()
                                    {
                                        item->proc();
                                        item->status=INativeDelay::Executed;
                                    });
                    }
                }
            }
            
            bool CocoaAsyncService::IsInMainThread(INativeWindow* window)
            {
                return Thread::GetCurrentThreadId() == mainThreadId;
            }
            
            void CocoaAsyncService::InvokeAsync(const Func<void()>& proc)
            {
                ThreadPoolLite::Queue(proc);
            }
            
            void CocoaAsyncService::InvokeInMainThread(INativeWindow* window, const Func<void()>& proc)
            {
                SPIN_LOCK(taskListLock)
                {
                    TaskItem item(0, proc);
                    taskItems.Add(item);
                }
            }
            
            bool CocoaAsyncService::InvokeInMainThreadAndWait(INativeWindow* window, const Func<void()>& proc, vint milliseconds)
            {
                Semaphore* semaphore = new Semaphore();
                semaphore->Create(0, 1);
                
                TaskItem item(semaphore, proc);
                SPIN_LOCK(taskListLock)
                {
                    taskItems.Add(item);
                }
                
                // todo, if semphoare fails to wait for some reason
                // taskItems will corrupt
                return semaphore->Wait();
                
//                if(milliseconds < 0)
//                {
//                    return semaphore.Wait();
//                }
//                else
//                {
//                    // todo
//                    return false;
//                    //return semaphore.WaitForTime(milliseconds);
//                }
            }
            
            Ptr<INativeDelay> CocoaAsyncService::DelayExecute(const Func<void()>& proc, vint milliseconds)
            {
                Ptr<DelayItem> delay;
                SPIN_LOCK(taskListLock)
                {
                    delay = new DelayItem(this, proc, false, milliseconds);
                    delayItems.Add(delay);
                }
                return delay;
            }
            
            Ptr<INativeDelay> CocoaAsyncService::DelayExecuteInMainThread(const Func<void()>& proc, vint milliseconds)
            {
                Ptr<DelayItem> delay;
                SPIN_LOCK(taskListLock)
                {
                    delay = new DelayItem(this, proc, true, milliseconds);
                    delayItems.Add(delay);
                }
                return delay;
            }
            

        }

    }

}