
public static func SendInputHintData(context: GameInstance, show: Bool, data: InputHintData, opt targetHintContainer: CName) -> Void {
  let evt: ref<UpdateInputHintEvent> = new UpdateInputHintEvent();
  evt.data = data;
  evt.show = show;
  if IsNameValid(targetHintContainer) {
    evt.targetHintContainer = targetHintContainer;
  };
  evt.targetHintContainer = n"GameplayInputHelper";
  GameInstance.GetUISystem(context).QueueEvent(evt);
}

public static exec func test_inputhint(gameInstance: GameInstance) -> Void {
  let data: InputHintData;
  data.action = n"UI_Apply";
  data.source = n"DebugDefault";
  data.localizedLabel = "Debug 1";
  data.queuePriority = 0;
  data.sortingPriority = 0;
  let evt: ref<UpdateInputHintEvent> = new UpdateInputHintEvent();
  evt.data = data;
  evt.show = true;
  evt.targetHintContainer = n"GameplayInputHelper";
  GameInstance.GetUISystem(gameInstance).QueueEvent(evt);
}

public static exec func test_inputhint1(gameInstance: GameInstance) -> Void {
  let data: InputHintData;
  data.action = n"UI_Cancel";
  data.source = n"Debug";
  data.localizedLabel = "Debug 2";
  data.queuePriority = 0;
  data.sortingPriority = 0;
  let evt: ref<UpdateInputHintEvent> = new UpdateInputHintEvent();
  evt.data = data;
  evt.show = true;
  evt.targetHintContainer = n"GameplayInputHelper";
  GameInstance.GetUISystem(gameInstance).QueueEvent(evt);
}

public static exec func test_group(gameInstance: GameInstance) -> Void {
  let data: InputHintGroupData;
  data.localizedTitle = "Test title";
  data.localizedDescription = "Test description";
  data.sortingPriority = 0;
  let evt: ref<AddInputGroupEvent> = new AddInputGroupEvent();
  evt.data = data;
  evt.groupId = n"test1";
  evt.targetHintContainer = n"GameplayInputHelper";
  GameInstance.GetUISystem(gameInstance).QueueEvent(evt);
}

public static exec func test_inputhint_clear(gameInstance: GameInstance) -> Void {
  let evt: ref<DeleteInputHintBySourceEvent> = new DeleteInputHintBySourceEvent();
  evt.source = n"Debug";
  evt.targetHintContainer = n"GameplayInputHelper";
  GameInstance.GetUISystem(gameInstance).QueueEvent(evt);
}
