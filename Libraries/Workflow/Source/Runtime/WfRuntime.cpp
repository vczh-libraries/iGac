#include "WfRuntime.h"

namespace vl
{
	namespace stream
	{
		namespace internal
		{
			using namespace reflection;
			using namespace reflection::description;
			using namespace workflow::runtime;
			using namespace collections;

			BEGIN_SERIALIZATION(WfAssemblyFunction)
				SERIALIZE(name)
				SERIALIZE(argumentNames)
				SERIALIZE(capturedVariableNames)
				SERIALIZE(localVariableNames)
				SERIALIZE(firstInstruction)
				SERIALIZE(lastInstruction)
			END_SERIALIZATION

			SERIALIZE_ENUM(WfInsCode)
			SERIALIZE_ENUM(WfInsType)
			SERIALIZE_ENUM(Value::ValueType)

			template<>
			struct Serialization<ITypeDescriptor*>
			{
				static void IO(Reader& reader, ITypeDescriptor*& value)
				{
					WString id;
					reader << id;
					value = GetTypeDescriptor(id);
					CHECK_ERROR(value, L"Failed to load type.");
				}
					
				static void IO(Writer& writer, ITypeDescriptor*& value)
				{
					WString id = value->GetTypeName();
					writer << id;
				}
			};

			template<>
			struct Serialization<IMethodInfo*>
			{
				static void IO(Reader& reader, IMethodInfo*& value)
				{
					ITypeDescriptor* type = 0;
					WString name;
					List<WString> parameters;
					reader << type << name << parameters;
					auto group =
						name == L"#ctor" ? type->GetConstructorGroup() :
						type->GetMethodGroupByName(name, false);
					CHECK_ERROR(group, L"Failed to load method.");

					value = 0;
					vint count = group->GetMethodCount();
					for (vint i = 0; i < count; i++)
					{
						auto method = group->GetMethod(i);
						if (method->GetParameterCount() == parameters.Count())
						{
							bool found = true;
							for (vint j = 0; j < parameters.Count(); j++)
							{
								if (method->GetParameter(j)->GetName() != parameters[j])
								{
									found = false;
									break;
								}
							}

							if (found)
							{
								CHECK_ERROR(!value, L"Failed to load method.");
								value = method;
							}
						}
					}
					CHECK_ERROR(value, L"Failed to load method.");
				}
					
				static void IO(Writer& writer, IMethodInfo*& value)
				{
					auto type = value->GetOwnerTypeDescriptor();
					WString name =
						value->GetOwnerMethodGroup() == type->GetConstructorGroup() ? L"#ctor" :
						value->GetName();
					writer << type << name;

					List<WString> parameters;
					vint count = value->GetParameterCount();
					for (vint i = 0; i < count; i++)
					{
						parameters.Add(value->GetParameter(i)->GetName());
					}
					writer << parameters;
				}
			};

			template<>
			struct Serialization<IPropertyInfo*>
			{
				static void IO(Reader& reader, IPropertyInfo*& value)
				{
					ITypeDescriptor* type = 0;
					WString name;
					reader << type << name;
					value = type->GetPropertyByName(name, false);
					CHECK_ERROR(value, L"Failed to load property.");
				}
					
				static void IO(Writer& writer, IPropertyInfo*& value)
				{
					auto type = value->GetOwnerTypeDescriptor();
					WString name = value->GetName();
					writer << type << name;
				}
			};

			template<>
			struct Serialization<IEventInfo*>
			{
				static void IO(Reader& reader, IEventInfo*& value)
				{
					ITypeDescriptor* type = 0;
					WString name;
					reader << type << name;
					value = type->GetEventByName(name, false);
					CHECK_ERROR(value, L"Failed to load event.");
				}
					
				static void IO(Writer& writer, IEventInfo*& value)
				{
					auto type = value->GetOwnerTypeDescriptor();
					WString name = value->GetName();
					writer << type << name;
				}
			};

			template<>
			struct Serialization<Value>
			{
				static void IO(Reader& reader, Value& value)
				{
					WString id, text;
					reader << id << text;
					if (id == L"")
					{
						value = Value();
					}
					else
					{
						auto type = GetTypeDescriptor(id);
						if (type == GetTypeDescriptor<ITypeDescriptor>())
						{
							type = GetTypeDescriptor(text);
							CHECK_ERROR(type, L"Failed to load type.");
							value = Value::From(type);
						}
						else
						{
							type->GetValueSerializer()->Parse(text, value);
						}
					}
				}
					
				static void IO(Writer& writer, Value& value)
				{
					WString id;
					if (value.GetTypeDescriptor())
					{
						id = value.GetTypeDescriptor()->GetTypeName();
					}
					writer << id;

					if (value.GetTypeDescriptor() == GetTypeDescriptor<ITypeDescriptor>())
					{
						WString text = UnboxValue<ITypeDescriptor*>(value)->GetTypeName();
						writer << text;
					}
					else
					{
						WString text = value.GetText();
						writer << text;
					}
				}
			};

			template<>
			struct Serialization<WfInstruction>
			{
				template<typename TIO>
				static void IO(TIO& io, WfInstruction& value)
				{
					io << value.code;
#define STREAMIO(NAME)						case WfInsCode::NAME: break;
#define STREAMIO_VALUE(NAME)				case WfInsCode::NAME: io << value.valueParameter; break;
#define STREAMIO_FUNCTION(NAME)				case WfInsCode::NAME: io << value.indexParameter; break;
#define STREAMIO_FUNCTION_COUNT(NAME)		case WfInsCode::NAME: io << value.indexParameter << value.countParameter; break;
#define STREAMIO_VARIABLE(NAME)				case WfInsCode::NAME: io << value.indexParameter; break;
#define STREAMIO_COUNT(NAME)				case WfInsCode::NAME: io << value.countParameter; break;
#define STREAMIO_FLAG_TYPEDESCRIPTOR(NAME)	case WfInsCode::NAME: io << value.flagParameter << value.typeDescriptorParameter; break;
#define STREAMIO_PROPERTY(NAME)				case WfInsCode::NAME: io << value.propertyParameter; break;
#define STREAMIO_METHOD_COUNT(NAME)			case WfInsCode::NAME: io << value.methodParameter << value.countParameter; break;
#define STREAMIO_EVENT(NAME)				case WfInsCode::NAME: io << value.eventParameter; break;
#define STREAMIO_LABEL(NAME)				case WfInsCode::NAME: io << value.indexParameter; break;
#define STREAMIO_TYPE(NAME)					case WfInsCode::NAME: io << value.typeParameter; break;

					switch (value.code)
					{
						INSTRUCTION_CASES(
							STREAMIO,
							STREAMIO_VALUE,
							STREAMIO_FUNCTION,
							STREAMIO_FUNCTION_COUNT,
							STREAMIO_VARIABLE,
							STREAMIO_COUNT,
							STREAMIO_FLAG_TYPEDESCRIPTOR,
							STREAMIO_PROPERTY,
							STREAMIO_METHOD_COUNT,
							STREAMIO_EVENT,
							STREAMIO_LABEL,
							STREAMIO_TYPE)
					}

#undef STREAMIO
#undef STREAMIO_VALUE
#undef STREAMIO_FUNCTION
#undef STREAMIO_FUNCTION_COUNT
#undef STREAMIO_VARIABLE
#undef STREAMIO_COUNT
#undef STREAMIO_FLAG_TYPEDESCRIPTOR
#undef STREAMIO_PROPERTY
#undef STREAMIO_METHOD_COUNT
#undef STREAMIO_EVENT
#undef STREAMIO_LABEL
#undef STREAMIO_TYPE
				}
			};
		}
	}

	namespace workflow
	{
		namespace runtime
		{
			using namespace reflection;
			using namespace reflection::description;

/***********************************************************************
WfInstruction
***********************************************************************/

			WfInstruction::WfInstruction()
				:flagParameter(Value::Null)
				, typeDescriptorParameter(0)
			{

			}

#define CTOR(NAME)\
	WfInstruction WfInstruction::NAME()\
			{\
			WfInstruction ins; \
			ins.code = WfInsCode::NAME; \
			return ins; \
			}\

#define CTOR_VALUE(NAME)\
	WfInstruction WfInstruction::NAME(const reflection::description::Value& value)\
			{\
			WfInstruction ins; \
			ins.code = WfInsCode::NAME; \
			ins.valueParameter = value; \
			return ins; \
			}\

#define CTOR_FUNCTION(NAME)\
	WfInstruction WfInstruction::NAME(vint function)\
			{\
			WfInstruction ins; \
			ins.code = WfInsCode::NAME; \
			ins.indexParameter = function; \
			return ins; \
			}\

#define CTOR_FUNCTION_COUNT(NAME)\
	WfInstruction WfInstruction::NAME(vint function, vint count)\
			{\
			WfInstruction ins; \
			ins.code = WfInsCode::NAME; \
			ins.indexParameter = function; \
			ins.countParameter = count; \
			return ins; \
			}\

#define CTOR_VARIABLE(NAME)\
	WfInstruction WfInstruction::NAME(vint variable)\
			{\
			WfInstruction ins; \
			ins.code = WfInsCode::NAME; \
			ins.indexParameter = variable; \
			return ins; \
			}\

#define CTOR_COUNT(NAME)\
	WfInstruction WfInstruction::NAME(vint count)\
			{\
			WfInstruction ins; \
			ins.code = WfInsCode::NAME; \
			ins.countParameter = count; \
			return ins; \
			}\

#define CTOR_FLAG_TYPEDESCRIPTOR(NAME)\
	WfInstruction WfInstruction::NAME(reflection::description::Value::ValueType flag, reflection::description::ITypeDescriptor* typeDescriptor)\
			{\
			WfInstruction ins; \
			ins.code = WfInsCode::NAME; \
			ins.flagParameter = flag; \
			ins.typeDescriptorParameter = typeDescriptor; \
			return ins; \
			}\

#define CTOR_PROPERTY(NAME)\
	WfInstruction WfInstruction::NAME(reflection::description::IPropertyInfo* propertyInfo)\
			{\
			WfInstruction ins; \
			ins.code = WfInsCode::NAME; \
			ins.propertyParameter = propertyInfo; \
			return ins; \
			}\

#define CTOR_METHOD_COUNT(NAME)\
	WfInstruction WfInstruction::NAME(reflection::description::IMethodInfo* methodInfo, vint count)\
			{\
			WfInstruction ins; \
			ins.code = WfInsCode::NAME; \
			ins.methodParameter = methodInfo; \
			ins.countParameter = count; \
			return ins; \
			}\

#define CTOR_EVENT(NAME)\
	WfInstruction WfInstruction::NAME(reflection::description::IEventInfo* eventInfo)\
			{\
			WfInstruction ins; \
			ins.code = WfInsCode::NAME; \
			ins.eventParameter = eventInfo; \
			return ins; \
			}\

#define CTOR_LABEL(NAME)\
	WfInstruction WfInstruction::NAME(vint label)\
			{\
			WfInstruction ins; \
			ins.code = WfInsCode::NAME; \
			ins.indexParameter = label; \
			return ins; \
			}\

#define CTOR_TYPE(NAME)\
	WfInstruction WfInstruction::NAME(WfInsType type)\
			{\
			WfInstruction ins; \
			ins.code = WfInsCode::NAME; \
			ins.typeParameter = type; \
			return ins; \
			}\

			INSTRUCTION_CASES(
				CTOR,
				CTOR_VALUE,
				CTOR_FUNCTION,
				CTOR_FUNCTION_COUNT,
				CTOR_VARIABLE,
				CTOR_COUNT,
				CTOR_FLAG_TYPEDESCRIPTOR,
				CTOR_PROPERTY,
				CTOR_METHOD_COUNT,
				CTOR_EVENT,
				CTOR_LABEL,
				CTOR_TYPE)

#undef CTOR
#undef CTOR_VALUE
#undef CTOR_FUNCTION
#undef CTOR_FUNCTION_COUNT
#undef CTOR_VARIABLE
#undef CTOR_COUNT
#undef CTOR_FLAG_TYPEDESCRIPTOR
#undef CTOR_PROPERTY
#undef CTOR_METHOD_COUNT
#undef CTOR_EVENT
#undef CTOR_LABEL
#undef CTOR_TYPE

/***********************************************************************
WfAssembly
***********************************************************************/

			template<typename TIO>
			void WfAssembly::IO(TIO& io)
			{
				io
					<< variableNames
					<< functionByName
					<< functions
					<< instructions
					;
			}

			WfAssembly::WfAssembly()
			{
			}

			WfAssembly::WfAssembly(stream::IStream& input)
			{
				stream::internal::Reader reader(input);
				IO(reader);
			}

			void WfAssembly::Serialize(stream::IStream& output)
			{
				stream::internal::Writer writer(output);
				IO(writer);
			}

/***********************************************************************
WfRuntimeGlobalContext
***********************************************************************/

			WfRuntimeGlobalContext::WfRuntimeGlobalContext(Ptr<WfAssembly> _assembly)
			:assembly(_assembly)
			{
				globalVariables = new WfRuntimeVariableContext;
				globalVariables->variables.Resize(assembly->variableNames.Count());
			}

/***********************************************************************
WfRuntimeThreadContext
***********************************************************************/

			WfRuntimeThreadContext::WfRuntimeThreadContext(Ptr<WfRuntimeGlobalContext> _context)
				:globalContext(_context)
			{
				stack.SetLessMemoryMode(false);
				stackFrames.SetLessMemoryMode(false);
			}

			WfRuntimeThreadContext::WfRuntimeThreadContext(Ptr<WfAssembly> _assembly)
				:globalContext(new WfRuntimeGlobalContext(_assembly))
			{
				stack.SetLessMemoryMode(false);
				stackFrames.SetLessMemoryMode(false);
			}

			WfRuntimeStackFrame& WfRuntimeThreadContext::GetCurrentStackFrame()
			{
				return stackFrames[stackFrames.Count() - 1];
			}

			WfRuntimeThreadContextError WfRuntimeThreadContext::PushStackFrame(vint functionIndex, vint argumentCount, Ptr<WfRuntimeVariableContext> capturedVariables)
			{
				if (stackFrames.Count() == 0)
				{
					if (stack.Count() < argumentCount)
					{
						return WfRuntimeThreadContextError::StackCorrupted;
					}
				}
				else
				{
					auto& frame = GetCurrentStackFrame();
					if (stack.Count() - frame.freeStackBase < argumentCount)
					{
						return WfRuntimeThreadContextError::StackCorrupted;
					}
				}
				if (functionIndex < 0 || functionIndex >= globalContext->assembly->functions.Count())
				{
					return WfRuntimeThreadContextError::WrongFunctionIndex;
				}
				auto meta = globalContext->assembly->functions[functionIndex];
				if (meta->argumentNames.Count() != argumentCount)
				{
					return WfRuntimeThreadContextError::WrongArgumentCount;
				}
				if (meta->capturedVariableNames.Count() == 0)
				{
					if (capturedVariables)
					{
						return WfRuntimeThreadContextError::WrongCapturedVariableCount;
					}
				}
				else
				{
					if (!capturedVariables || capturedVariables->variables.Count() != meta->capturedVariableNames.Count())
					{
						return WfRuntimeThreadContextError::WrongCapturedVariableCount;
					}
				}

				WfRuntimeStackFrame frame;
				frame.capturedVariables = capturedVariables;
				frame.functionIndex = functionIndex;
				frame.nextInstructionIndex = globalContext->assembly->functions[functionIndex]->firstInstruction;
				frame.stackBase = stack.Count() - argumentCount;

				frame.fixedVariableCount = meta->argumentNames.Count() + meta->localVariableNames.Count();
				frame.freeStackBase = frame.stackBase + frame.fixedVariableCount;
				stackFrames.Add(frame);

				for (vint i = 0; i < meta->localVariableNames.Count(); i++)
				{
					stack.Add(Value());
				}
				if (status == WfRuntimeExecutionStatus::Finished || status == WfRuntimeExecutionStatus::FatalError)
				{
					status = WfRuntimeExecutionStatus::Ready;
				}
				return WfRuntimeThreadContextError::Success;
			}

			WfRuntimeThreadContextError WfRuntimeThreadContext::PopStackFrame()
			{
				if (stackFrames.Count() == 0) return WfRuntimeThreadContextError::EmptyStackFrame;
				WfRuntimeStackFrame frame = GetCurrentStackFrame();
				if (trapFrames.Count() > 0)
				{
					WfRuntimeTrapFrame& trapFrame = GetCurrentTrapFrame();
					if (trapFrame.stackFrameIndex == stackFrames.Count() - 1)
					{
						return WfRuntimeThreadContextError::TrapFrameCorrupted;
					}
				}
				stackFrames.RemoveAt(stackFrames.Count() - 1);

				if (stack.Count() > frame.stackBase)
				{
					stack.RemoveRange(frame.stackBase, stack.Count() - frame.stackBase);
				}
				return WfRuntimeThreadContextError::Success;
			}

			WfRuntimeTrapFrame& WfRuntimeThreadContext::GetCurrentTrapFrame()
			{
				return trapFrames[trapFrames.Count() - 1];
			}

			WfRuntimeThreadContextError WfRuntimeThreadContext::PushTrapFrame(vint instructionIndex)
			{
				WfRuntimeTrapFrame frame;
				frame.stackFrameIndex = stackFrames.Count() - 1;
				frame.instructionIndex = instructionIndex;
				frame.stackPatternCount = stack.Count();
				trapFrames.Add(frame);
				return WfRuntimeThreadContextError::Success;
			}

			WfRuntimeThreadContextError WfRuntimeThreadContext::PopTrapFrame(vint saveStackPatternCount)
			{
				if (trapFrames.Count() == 0) return WfRuntimeThreadContextError::EmptyTrapFrame;
				WfRuntimeTrapFrame& frame = trapFrames[trapFrames.Count() - 1];
				if (frame.stackFrameIndex != stackFrames.Count() - 1) return WfRuntimeThreadContextError::TrapFrameCorrupted;

				vint stackPopCount = stack.Count() - frame.stackPatternCount - saveStackPatternCount;
				if (stackPopCount < 0)
				{
					return WfRuntimeThreadContextError::StackCorrupted;
				}
				else if (stackPopCount>0)
				{
					stack.RemoveRange(stack.Count() - stackPopCount, stackPopCount);
				}

				trapFrames.RemoveAt(trapFrames.Count() - 1);
				return WfRuntimeThreadContextError::Success;
			}

			WfRuntimeThreadContextError WfRuntimeThreadContext::PushValue(const reflection::description::Value& value)
			{
				stack.Add(value);
				return WfRuntimeThreadContextError::Success;
			}

			WfRuntimeThreadContextError WfRuntimeThreadContext::PopValue(reflection::description::Value& value)
			{
				if (stackFrames.Count() == 0)
				{
					if (stack.Count() == 0) return WfRuntimeThreadContextError::EmptyStack;
				}
				else
				{
					WfRuntimeStackFrame& frame = GetCurrentStackFrame();
					if (stack.Count() <= frame.freeStackBase) return WfRuntimeThreadContextError::StackCorrupted;
				}
				value = stack[stack.Count() - 1];
				stack.RemoveAt(stack.Count() - 1);
				return WfRuntimeThreadContextError::Success;
			}

			WfRuntimeThreadContextError WfRuntimeThreadContext::RaiseException(const WString& exception, bool fatalError)
			{
				exceptionValue = exception;
				status = fatalError ? WfRuntimeExecutionStatus::FatalError : WfRuntimeExecutionStatus::RaisedException;
				return WfRuntimeThreadContextError::Success;
			}

			WfRuntimeThreadContextError WfRuntimeThreadContext::LoadStackValue(vint stackItemIndex, reflection::description::Value& value)
			{
				if (stackFrames.Count() == 0) return WfRuntimeThreadContextError::EmptyStackFrame;
				auto frame = GetCurrentStackFrame();
				if (stackItemIndex < frame.freeStackBase || stackItemIndex >= stack.Count())
				{
					return WfRuntimeThreadContextError::WrongVariableIndex;
				}

				value = stack[stackItemIndex];
				return WfRuntimeThreadContextError::Success;
			}

			WfRuntimeThreadContextError WfRuntimeThreadContext::LoadGlobalVariable(vint variableIndex, reflection::description::Value& value)
			{
				if (variableIndex < 0 || variableIndex >= globalContext->globalVariables->variables.Count())
				{
					return WfRuntimeThreadContextError::WrongVariableIndex;
				}

				value = globalContext->globalVariables->variables[variableIndex];
				return WfRuntimeThreadContextError::Success;
			}

			WfRuntimeThreadContextError WfRuntimeThreadContext::StoreGlobalVariable(vint variableIndex, const reflection::description::Value& value)
			{
				if (variableIndex < 0 || variableIndex >= globalContext->globalVariables->variables.Count())
				{
					return WfRuntimeThreadContextError::WrongVariableIndex;
				}

				globalContext->globalVariables->variables[variableIndex] = value;
				return WfRuntimeThreadContextError::Success;
			}

			WfRuntimeThreadContextError WfRuntimeThreadContext::LoadCapturedVariable(vint variableIndex, reflection::description::Value& value)
			{
				if (stackFrames.Count() == 0) return WfRuntimeThreadContextError::EmptyStackFrame;
				auto frame = GetCurrentStackFrame();
				if (variableIndex < 0 || variableIndex >= frame.capturedVariables->variables.Count())
				{
					return WfRuntimeThreadContextError::WrongVariableIndex;
				}

				value = frame.capturedVariables->variables[variableIndex];
				return WfRuntimeThreadContextError::Success;
			}

			WfRuntimeThreadContextError WfRuntimeThreadContext::LoadLocalVariable(vint variableIndex, reflection::description::Value& value)
			{
				if (stackFrames.Count() == 0) return WfRuntimeThreadContextError::EmptyStackFrame;
				auto frame = GetCurrentStackFrame();
				if (variableIndex < 0 || variableIndex >= frame.fixedVariableCount)
				{
					return WfRuntimeThreadContextError::WrongVariableIndex;
				}

				value = stack[frame.stackBase + variableIndex];
				return WfRuntimeThreadContextError::Success;
			}

			WfRuntimeThreadContextError WfRuntimeThreadContext::StoreLocalVariable(vint variableIndex, const reflection::description::Value& value)
			{
				if (stackFrames.Count() == 0) return WfRuntimeThreadContextError::EmptyStackFrame;
				auto frame = GetCurrentStackFrame();
				if (variableIndex < 0 || variableIndex >= frame.fixedVariableCount)
				{
					return WfRuntimeThreadContextError::WrongVariableIndex;
				}

				stack[frame.stackBase + variableIndex] = value;
				return WfRuntimeThreadContextError::Success;
			}

			void WfRuntimeThreadContext::ExecuteToEnd()
			{
				while (Execute() != WfRuntimeExecutionAction::Nop);
			}
		}
	}
}