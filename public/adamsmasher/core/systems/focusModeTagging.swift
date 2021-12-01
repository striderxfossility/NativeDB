
public class TagObjectEvent extends Event {

  public edit let isTagged: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Tag Object";
  }
}

public class FocusModeTaggingSystem extends ScriptableSystem {

  private let m_playerAttachedCallbackID: Uint32;

  private let m_playerDetachedCallbackID: Uint32;

  private let m_taggedListenerCallbacks: array<ref<CallbackHandle>>;

  private func OnAttach() -> Void {
    this.RegisterPlayerAttachedCallback();
    this.RegisterPlayerDetachedCallback();
  }

  private func OnDetach() -> Void {
    this.UnregisterPlayerAttachedCallback();
    this.UnregisterPlayerDetachedCallback();
  }

  protected final func RegisterPlayerAttachedCallback() -> Void {
    if this.m_playerAttachedCallbackID == 0u {
      this.m_playerAttachedCallbackID = GameInstance.GetPlayerSystem(this.GetGameInstance()).RegisterPlayerPuppetAttachedCallback(this, n"OnPlayerAttachedCallback");
    };
  }

  protected final func UnregisterPlayerAttachedCallback() -> Void {
    if this.m_playerAttachedCallbackID > 0u {
      GameInstance.GetPlayerSystem(this.GetGameInstance()).UnregisterPlayerPuppetAttachedCallback(this.m_playerAttachedCallbackID);
      this.m_playerAttachedCallbackID = 0u;
    };
  }

  protected final func RegisterPlayerDetachedCallback() -> Void {
    if this.m_playerDetachedCallbackID == 0u {
      this.m_playerDetachedCallbackID = GameInstance.GetPlayerSystem(this.GetGameInstance()).RegisterPlayerPuppetDetachedCallback(this, n"OnPlayerDetachedCallback");
    };
  }

  protected final func UnregisterPlayerDetachedCallback() -> Void {
    if this.m_playerDetachedCallbackID > 0u {
      GameInstance.GetPlayerSystem(this.GetGameInstance()).UnregisterPlayerPuppetDetachedCallback(this.m_playerDetachedCallbackID);
      this.m_playerDetachedCallbackID = 0u;
    };
  }

  private final func OnPlayerAttachedCallback(playerPuppet: ref<GameObject>) -> Void {
    this.Register(playerPuppet);
  }

  private final func OnPlayerDetachedCallback(playerPuppet: ref<GameObject>) -> Void {
    this.Unregister(playerPuppet);
  }

  protected final func GetPlayerStateMachineBlackboard(playerPuppet: wref<GameObject>) -> ref<IBlackboard> {
    let blackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return blackboard;
  }

  private final func GetScannerTargetID() -> EntityID {
    let blackBoard: ref<IBlackboard>;
    let entityID: EntityID;
    if GameInstance.GetRuntimeInfo(this.GetGameInstance()).IsMultiplayer() {
      return entityID;
    };
    blackBoard = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_Scanner);
    entityID = blackBoard.GetEntityID(GetAllBlackboardDefs().UI_Scanner.ScannedObject);
    return entityID;
  }

  private final const func GetNetworkSystem() -> ref<NetworkSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"NetworkSystem") as NetworkSystem;
  }

  private final const func GetHudManager() -> ref<HUDManager> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"HUDManager") as HUDManager;
  }

  public final const func RequestUntagAll() -> Void {
    let request: ref<UnTagAllObjectRequest> = new UnTagAllObjectRequest();
    this.QueueRequest(request);
  }

  private final func Register(source: ref<GameObject>) -> Void {
    source.RegisterInputListenerWithOwner(this, n"TagButton");
  }

  private final func Unregister(source: ref<GameObject>) -> Void {
    source.UnregisterInputListener(this);
  }

  private final func TagObject(target: ref<GameObject>) -> Void {
    if !this.CanTag() || !target.CanBeTagged() {
      return;
    };
    GameInstance.GetVisionModeSystem(this.GetGameInstance()).GetScanningController().TagObject(target);
    this.SendForceRevealObjectEvent(true, target);
    this.RefreshUI(target);
    this.NotifyHudManager(true, target);
    this.RegisterObjectToBlackboard(target);
  }

  private final func UntagObject(target: ref<GameObject>) -> Void {
    GameInstance.GetVisionModeSystem(this.GetGameInstance()).GetScanningController().UntagObject(target);
    this.SendForceRevealObjectEvent(false, target);
    this.RefreshUI(target);
    this.NotifyNetworkSystem();
    this.NotifyHudManager(false, target);
    this.UnRegisterObjectToBlackboard(target);
  }

  private final func UntagAll() -> Void {
    let i: Int32;
    let object: wref<GameObject>;
    let listOfObjects: array<wref<GameObject>> = this.GetTaggedObjectsList();
    GameInstance.GetVisionModeSystem(this.GetGameInstance()).GetScanningController().UntagAll();
    this.UnRegisterAllObjectToBlackboard();
    i = 0;
    while i < ArraySize(listOfObjects) {
      object = listOfObjects[i];
      if !IsDefined(object) {
      } else {
        this.SendForceRevealObjectEvent(false, object);
        this.RefreshUI(object);
        this.NotifyNetworkSystem();
        this.NotifyHudManager(false, object);
      };
      i += 1;
    };
  }

  private final func ResolveFocusClues(tag: Bool, target: ref<GameObject>) -> Void {
    let clueRequest: ref<TagLinkedCluekRequest>;
    let linkedClueData: LinkedFocusClueData;
    let clueIndex: Int32 = target.GetAvailableClueIndex();
    if clueIndex >= 0 {
      linkedClueData = target.GetLinkedClueData(clueIndex);
      if IsNameValid(linkedClueData.clueGroupID) {
        clueRequest = new TagLinkedCluekRequest();
        clueRequest.tag = tag;
        clueRequest.linkedCluekData = linkedClueData;
        target.GetFocusClueSystem().QueueRequest(clueRequest);
      };
    };
  }

  private final func SendForceRevealObjectEvent(reveal: Bool, target: ref<GameObject>) -> Void {
    let evt: ref<RevealObjectEvent> = new RevealObjectEvent();
    evt.reveal = reveal;
    evt.reason.reason = n"tag";
    target.QueueEvent(evt);
  }

  private final func SendForceVisionApperaceEvent(enable: Bool, target: ref<GameObject>, highlightType: EFocusForcedHighlightType) -> Void {
    let evt: ref<ForceVisionApperanceEvent> = new ForceVisionApperanceEvent();
    let highlight: ref<FocusForcedHighlightData> = new FocusForcedHighlightData();
    highlight.sourceID = target.GetEntityID();
    highlight.sourceName = this.GetClassName();
    highlight.highlightType = highlightType;
    highlight.priority = EPriority.Absolute;
    evt.forcedHighlight = highlight;
    evt.apply = enable;
    target.QueueEvent(evt);
  }

  private final const func IsTagged(target: ref<GameObject>) -> Bool {
    if target != null {
      return GameInstance.GetVisionModeSystem(this.GetGameInstance()).GetScanningController().IsTagged(target);
    };
    return false;
  }

  private final func IsPlayerAiming(playerPuppet: wref<GameObject>) -> Bool {
    return this.GetPlayerStateMachineBlackboard(playerPuppet).GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim);
  }

  private final func IsPlayerInFocusMode(playerPuppet: wref<GameObject>) -> Bool {
    return this.GetPlayerStateMachineBlackboard(playerPuppet).GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus);
  }

  public final const func CanTag() -> Bool {
    let player: ref<GameObject> = GetPlayer(this.GetGameInstance());
    let statValue: Float = GameInstance.GetStatsSystem(this.GetGameInstance()).GetStatValue(Cast(player.GetEntityID()), gamedataStatType.HasCybereye);
    let canScan: Bool = !StatusEffectSystem.ObjectHasStatusEffect(player, t"GameplayRestriction.NoScanning");
    return statValue > 0.00 && canScan;
  }

  protected cb func OnActionWithOwner(action: ListenerAction, consumer: ListenerActionConsumer, owner: wref<GameObject>) -> Bool {
    let isTaggable: Bool;
    let target: ref<GameObject>;
    if IsDefined(owner) && this.IsPlayerInFocusMode(owner) {
      if Equals(ListenerAction.GetName(action), n"TagButton") && ListenerAction.IsButtonJustPressed(action) {
        if GameInstance.GetRuntimeInfo(owner.GetGame()).IsMultiplayer() && GameInstance.GetRuntimeInfo(owner.GetGame()).IsClient() {
          return false;
        };
        isTaggable = true;
        target = GameInstance.FindEntityByID(this.GetGameInstance(), this.GetScannerTargetID()) as GameObject;
        if !IsDefined(target) {
          target = GameInstance.GetTargetingSystem(this.GetGameInstance()).GetLookAtObject(owner, true, true);
        };
        if !IsDefined(target) {
          target = GameInstance.GetTargetingSystem(this.GetGameInstance()).GetLookAtObject(owner, false);
          isTaggable = IsDefined(target) ? target.IsObjectRevealed() : false;
        };
        if IsDefined(target) {
          if !this.IsTagged(target) {
            if isTaggable {
              this.TagObject(target);
              this.ResolveFocusClues(true, target);
            };
          } else {
            this.UntagObject(target);
            this.ResolveFocusClues(false, target);
          };
        };
      };
    };
  }

  private final func OnTagObjectRequest(request: ref<TagObjectRequest>) -> Void {
    this.TagObject(request.object);
  }

  private final func OnUnTagObjectRequest(request: ref<UnTagObjectRequest>) -> Void {
    this.UntagObject(request.object);
  }

  private final func OnUnTagAllObjectRequest(request: ref<UnTagAllObjectRequest>) -> Void {
    this.UntagAll();
  }

  private final func OnRegisterInputListenerRequest(request: ref<RegisterInputListenerRequest>) -> Void {
    this.Register(request.object);
  }

  private final func OnUnRegisterInputListenerRequest(request: ref<UnRegisterInputListenerRequest>) -> Void {
    this.Unregister(request.object);
  }

  private final func OnRegisterLitenerToTaggedList(request: ref<RegisterToListListener>) -> Void {
    this.AddTaggedListener(request.object, request.funcName);
  }

  private final func NotifyNetworkSystem() -> Void {
    let updateNetworkRequest: ref<UpdateNetworkVisualisationRequest>;
    let playerPuppet: ref<GameObject> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject();
    if this.IsPlayerInFocusMode(playerPuppet) {
      updateNetworkRequest = new UpdateNetworkVisualisationRequest();
      this.GetNetworkSystem().QueueRequest(updateNetworkRequest);
    };
  }

  private final func NotifyHudManager(isTagged: Bool, target: ref<GameObject>) -> Void {
    let request: ref<TagStatusNotification> = new TagStatusNotification();
    request.isTagged = isTagged;
    request.ownerID = target.GetEntityID();
    this.GetHudManager().QueueRequest(request);
  }

  private final func RefreshUI(target: ref<GameObject>) -> Void {
    let uiBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_Scanner);
    uiBlackboard.SetVariant(GetAllBlackboardDefs().UI_Scanner.LastTaggedTarget, ToVariant(target), true);
  }

  private final func RegisterObjectToBlackboard(target: ref<GameObject>) -> Void {
    let BBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().TaggedObjectsList);
    let listOfObjects: array<wref<GameObject>> = FromVariant(BBoard.GetVariant(GetAllBlackboardDefs().TaggedObjectsList.taggedObjectsList));
    this.CleanupTaggedObjects(listOfObjects);
    ArrayInsert(listOfObjects, 0, target);
    BBoard.SetVariant(GetAllBlackboardDefs().TaggedObjectsList.taggedObjectsList, ToVariant(listOfObjects));
  }

  private final func UnRegisterObjectToBlackboard(target: ref<GameObject>) -> Void {
    let listOfObjects: array<wref<GameObject>> = this.GetTaggedObjectsList();
    ArrayRemove(listOfObjects, target);
    GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().TaggedObjectsList).SetVariant(GetAllBlackboardDefs().TaggedObjectsList.taggedObjectsList, ToVariant(listOfObjects));
  }

  private final func UnRegisterAllObjectToBlackboard() -> Void {
    let listOfObjects: array<wref<GameObject>>;
    GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().TaggedObjectsList).SetVariant(GetAllBlackboardDefs().TaggedObjectsList.taggedObjectsList, ToVariant(listOfObjects));
  }

  private final func GetTaggedObjectsList() -> array<wref<GameObject>> {
    let listOfObjects: array<wref<GameObject>>;
    let BBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().TaggedObjectsList);
    let listOfObjectsVariant: Variant = BBoard.GetVariant(GetAllBlackboardDefs().TaggedObjectsList.taggedObjectsList);
    if VariantIsValid(listOfObjectsVariant) {
      listOfObjects = FromVariant(listOfObjectsVariant);
    };
    this.CleanupTaggedObjects(listOfObjects);
    return listOfObjects;
  }

  private final func AddTaggedListener(object: ref<GameObject>, funcName: CName) -> Void {
    let BBoard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().TaggedObjectsList);
    let callback: ref<CallbackHandle> = BBoard.RegisterListenerVariant(GetAllBlackboardDefs().TaggedObjectsList.taggedObjectsList, object, funcName);
    BBoard.Signal(GetAllBlackboardDefs().TaggedObjectsList.taggedObjectsList);
    ArrayPush(this.m_taggedListenerCallbacks, callback);
  }

  private final const func CleanupTaggedObjects(out listToClean: array<wref<GameObject>>) -> Void {
    let i: Int32 = ArraySize(listToClean) - 1;
    i;
    while i >= 0 {
      if listToClean[i] == null {
        ArrayErase(listToClean, i);
      };
      i -= 1;
    };
  }
}
