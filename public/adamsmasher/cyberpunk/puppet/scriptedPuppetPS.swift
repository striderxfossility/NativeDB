
public struct SecuritySystemData {

  public persistent let suppressIncomingEvents: Bool;

  public persistent let suppressOutgoingEvents: Bool;

  public final static func AreIncomingEventsSuppressed(self: SecuritySystemData) -> Bool {
    return self.suppressIncomingEvents;
  }

  public final static func AreOutgoingEventsSuppressed(self: SecuritySystemData) -> Bool {
    return self.suppressOutgoingEvents;
  }
}

public class ScriptedPuppetPS extends GamePuppetPS {

  private let m_deviceLink: wref<PuppetDeviceLinkPS>;

  private let m_cooldownStorage: ref<CooldownStorage>;

  private persistent let m_isInitialized: EBOOL;

  private persistent let m_wasAttached: Bool;

  protected persistent let m_wasRevealedInNetworkPing: Bool;

  private let m_numberActions: Int32;

  protected let m_wasQuickHackAttempt: Bool;

  protected let m_hasDirectInteractionChoicesActive: Bool;

  private persistent let m_wasIncapacitated: Bool;

  private persistent let m_isBreached: Bool;

  private persistent let m_isDead: Bool;

  private persistent let m_isIncapacitated: Bool;

  private persistent let m_isAndroidTurnedOff: Bool;

  private persistent let m_securitySystemData: SecuritySystemData;

  private let m_activeContexts: array<gamedeviceRequestType>;

  protected let m_lastInteractionLayerTag: CName;

  private persistent let m_quickHacksExposed: Bool;

  private let m_currentCooldownID: Uint32;

  private persistent let m_reactionPresetID: TweakDBID;

  @default(ScriptedPuppetPS, true)
  private persistent let m_isDefeatMechanicActive: Bool;

  private persistent let m_leftHandLoadout: ItemID;

  private persistent let m_rightHandLoadout: ItemID;

  protected cb func OnInstantiated() -> Bool {
    if !this.IsInitialized() {
      this.Initialize();
    };
  }

  private final func Initialize() -> Void {
    this.m_isInitialized = EBOOL.TRUE;
  }

  public final const func IsInitialized() -> Bool {
    return Equals(this.m_isInitialized, EBOOL.TRUE);
  }

  public final const func WasAttached() -> Bool {
    return this.m_wasAttached;
  }

  protected final func OnGameAttached(evt: ref<GameAttachedEvent>) -> EntityNotificationType {
    this.m_wasAttached = true;
    if !this.IsInitialized() {
      this.Initialize();
    };
    this.InitializeCooldownStorage();
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func InitializeCooldownStorage() -> Void {
    if !IsDefined(this.m_cooldownStorage) {
      this.m_cooldownStorage = new CooldownStorage();
      this.m_cooldownStorage.Initialize(this.GetID(), this.GetClassName(), this.GetGameInstance());
    };
  }

  protected final const func ExecutePSAction(action: ref<ScriptableDeviceAction>, persistentState: ref<PersistentState>) -> Void {
    if !EntityID.IsDefined(action.GetRequesterID()) {
      action.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
    };
    GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSEvent(persistentState.GetID(), persistentState.GetClassName(), action);
  }

  public final func GetCooldownStorage() -> ref<CooldownStorage> {
    return this.m_cooldownStorage;
  }

  public final func GetPlayerCooldownStorage() -> ref<CooldownStorage> {
    let player: ref<PlayerPuppet> = this.GetPlayerMainObject() as PlayerPuppet;
    if IsDefined(player) {
      return player.GetCooldownStorage();
    };
    return null;
  }

  protected final const func GetPlayerMainObject() -> ref<GameObject> {
    return GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject();
  }

  public final const func GetSecurityAreas(opt includeInactive: Bool, opt returnOnlyDirectlyConnected: Bool) -> array<ref<SecurityAreaControllerPS>> {
    return this.GetDeviceLink().GetSecurityAreas(includeInactive, returnOnlyDirectlyConnected);
  }

  public final const func GetSecuritySystem() -> ref<SecuritySystemControllerPS> {
    let secSys: ref<SecuritySystemControllerPS>;
    let link: ref<PuppetDeviceLinkPS> = this.GetDeviceLink();
    if IsDefined(link) {
      secSys = link.GetSecuritySystem();
      if IsDefined(secSys) && !secSys.IsDisabled() {
        return secSys;
      };
    };
    return null;
  }

  public final func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> EntityNotificationType {
    if evt.GetOriginalInputEvent().HasCustomRecipients() {
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final const func DetermineSecurityAreaTypeForEntityID(entityID: EntityID) -> ESecurityAreaType {
    if IsDefined(this.GetDeviceLink()) {
      return this.GetDeviceLink().GetSecuritySystem().DetermineSecurityAreaTypeForEntityID(entityID);
    };
    return ESecurityAreaType.DISABLED;
  }

  public final const func GetAccessPoint() -> ref<AccessPointControllerPS> {
    if IsDefined(this.GetDeviceLink()) {
      return this.GetDeviceLink().GetBackdoorAccessPoint();
    };
    return null;
  }

  public final const func GetWasIncapacitated() -> Bool {
    return this.m_wasIncapacitated;
  }

  public final const func IsConnectedToAccessPoint() -> Bool {
    if IsDefined(this.GetDeviceLink()) {
      return this.GetDeviceLink().HasNetworkBackdoor();
    };
    return false;
  }

  public final const func IsConnectedToSecuritySystem() -> Bool {
    if IsDefined(this.GetDeviceLink()) {
      return this.GetDeviceLink().IsConnectedToSecuritySystem();
    };
    return false;
  }

  public final const func GetNPCsConnectedToThisAPCount() -> Int32 {
    return 666;
  }

  public final const func GetNetworkName() -> String {
    if IsDefined(this.GetDeviceLink()) {
      return this.GetDeviceLink().GetNetworkName();
    };
    return "";
  }

  public final const func CheckMasterConnectedClassTypes() -> ConnectedClassTypes {
    let emptyReturn: ConnectedClassTypes;
    if IsDefined(this.GetDeviceLink()) {
      return this.GetDeviceLink().CheckMasterConnectedClassTypes();
    };
    return emptyReturn;
  }

  public final const func GetActiveContexts() -> array<gamedeviceRequestType> {
    return this.m_activeContexts;
  }

  public final const func HasDirectInteractionChoicesActive() -> Bool {
    return this.m_hasDirectInteractionChoicesActive;
  }

  public final func SetHasDirectInteractionChoicesActive(hasInteraction: Bool) -> Void {
    this.m_hasDirectInteractionChoicesActive = hasInteraction;
  }

  public final const func GetLeftHandLoadout() -> ItemID {
    return this.m_leftHandLoadout;
  }

  public final const func GetRightHandLoadout() -> ItemID {
    return this.m_rightHandLoadout;
  }

  public final const func DrawBetweenEntities(shouldDraw: Bool, focusModeOnly: Bool, fxResource: FxResource, masterID: EntityID, slaveID: EntityID, revealMaster: Bool, revealSlave: Bool, opt onlyRemoveWeakLink: Bool, opt isEyeContact: Bool) -> Void {
    let currentID: EntityID;
    let masterPuppet: ref<ScriptedPuppet>;
    let newLink: SNetworkLinkData;
    let registerLinkRequest: ref<RegisterNetworkLinkRequest>;
    let slavePuppet: ref<ScriptedPuppet>;
    let unregisterLinkRequest: ref<UnregisterNetworkLinkBetweenTwoEntitiesRequest>;
    let unregisterLinkRequestByID: ref<UnregisterNetworkLinksByIDRequest>;
    newLink.slaveID = slaveID;
    newLink.masterID = masterID;
    if shouldDraw {
      masterPuppet = GameInstance.FindEntityByID(this.GetGameInstance(), masterID) as ScriptedPuppet;
      slavePuppet = GameInstance.FindEntityByID(this.GetGameInstance(), slaveID) as ScriptedPuppet;
      newLink.weakLink = isEyeContact;
      if masterPuppet != null {
        newLink.masterPos = masterPuppet.GetWorldPosition();
      };
      if slavePuppet != null {
        newLink.slavePos = slavePuppet.GetWorldPosition();
      };
      newLink.linkType = ELinkType.NETWORK;
      newLink.isDynamic = true;
      newLink.fxResource = fxResource;
      newLink.revealMaster = revealMaster;
      newLink.revealSlave = revealSlave;
      newLink.drawLink = true;
      if focusModeOnly {
        newLink.isNetrunner = true;
      } else {
        newLink.isPing = true;
      };
      registerLinkRequest = new RegisterNetworkLinkRequest();
      ArrayPush(registerLinkRequest.linksData, newLink);
      this.GetNetworkSystem().QueueRequest(registerLinkRequest);
    } else {
      if EntityID.IsDefined(masterID) && EntityID.IsDefined(slaveID) {
        unregisterLinkRequest = new UnregisterNetworkLinkBetweenTwoEntitiesRequest();
        unregisterLinkRequest.firstID = slaveID;
        unregisterLinkRequest.secondID = masterID;
        unregisterLinkRequest.onlyRemoveWeakLink = onlyRemoveWeakLink;
        this.GetNetworkSystem().QueueRequest(unregisterLinkRequest);
      } else {
        if EntityID.IsDefined(masterID) {
          currentID = masterID;
        } else {
          if EntityID.IsDefined(slaveID) {
            currentID = slaveID;
          };
        };
        unregisterLinkRequestByID = new UnregisterNetworkLinksByIDRequest();
        unregisterLinkRequestByID.ID = currentID;
        this.GetNetworkSystem().QueueRequest(unregisterLinkRequestByID);
      };
    };
  }

  protected final const func GetOwnerEntity() -> wref<ScriptedPuppet> {
    return GameInstance.FindEntityByID(this.GetGameInstance(), PersistentID.ExtractEntityID(this.GetID())) as ScriptedPuppet;
  }

  private final const func CanPerformReprimend() -> Bool {
    return true;
  }

  public final const func IsQuickHacksExposed() -> Bool {
    if this.GetNetworkSystem().QuickHacksExposedByDefault() {
      if Equals(this.GetOwnerEntity().GetAttitudeTowards(GetPlayer(this.GetGameInstance())), EAIAttitude.AIA_Friendly) {
        return false;
      };
      return true;
    };
    if GetFact(this.GetGameInstance(), n"cheat_expose_npc_quick_hacks") > 0 {
      return true;
    };
    return this.m_quickHacksExposed;
  }

  public final const func WasRevealedInNetworkPing() -> Bool {
    return this.m_wasRevealedInNetworkPing || this.GetDeviceLink().WasRevealedInNetworkPing();
  }

  public final func SetRevealedInNetworkPing(wasRevealed: Bool) -> Void {
    if Equals(this.m_wasRevealedInNetworkPing, wasRevealed) {
      return;
    };
    this.m_wasRevealedInNetworkPing = wasRevealed;
    this.GetDeviceLink().SetRevealedInNetworkPing(this.m_wasRevealedInNetworkPing);
  }

  protected final const func GetNetworkSystem() -> ref<NetworkSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"NetworkSystem") as NetworkSystem;
  }

  public final func OnDeviceAttachment(evt: ref<DeviceLinkEstablished>) -> EntityNotificationType {
    this.m_deviceLink = evt.deviceLinkPS as PuppetDeviceLinkPS;
    if !IsFinal() {
      LogDevices(this, "CommunityProxyPS received");
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnSetWasQuickHacked(evt: ref<SetQuickHackEvent>) -> EntityNotificationType {
    this.SetWasQuickHacked(evt.wasQuickHacked);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnSetWasQuickHackedAtempt(evt: ref<SetQuickHackAttemptEvent>) -> EntityNotificationType {
    this.m_wasQuickHackAttempt = evt.wasQuickHackAttempt;
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final const func GetDeviceLink() -> ref<PuppetDeviceLinkPS> {
    let evt: ref<AcquireDeviceLink>;
    let link: ref<PuppetDeviceLinkPS>;
    if IsDefined(this.m_deviceLink) {
      return this.m_deviceLink;
    };
    link = PuppetDeviceLinkPS.AcquirePuppetDeviceLink(this.GetGameInstance(), this.GetMyEntityID());
    if IsDefined(link) {
      evt = new AcquireDeviceLink();
      GameInstance.GetPersistencySystem(this.GetGameInstance()).QueuePSEvent(this.GetID(), this.GetClassName(), evt);
      return link;
    };
    return null;
  }

  private final func OnAcquireDeviceLink(evt: ref<AcquireDeviceLink>) -> EntityNotificationType {
    if !IsDefined(this.m_deviceLink) {
      this.m_deviceLink = PuppetDeviceLinkPS.AcquirePuppetDeviceLink(this.GetGameInstance(), this.GetMyEntityID());
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func SetIsBreached(isBreached: Bool) -> Void {
    this.m_isBreached = isBreached;
  }

  public final const func IsBreached() -> Bool {
    return this.m_isBreached || this.GetDeviceLink().IsBreached();
  }

  public final const func GetOwnerEntityWeak() -> wref<Entity> {
    return GameInstance.FindEntityByID(this.GetGameInstance(), this.GetMyEntityID());
  }

  protected final const func GetMyEntityID() -> EntityID {
    return PersistentID.ExtractEntityID(this.GetID());
  }

  public final func SetWasIncapacitated(wasIncapacitated: Bool) -> Void {
    this.m_wasIncapacitated = wasIncapacitated;
    if wasIncapacitated {
      this.m_leftHandLoadout = new ItemID();
      this.m_rightHandLoadout = new ItemID();
    };
  }

  public final func OnCacheLoadout(evt: ref<CacheItemEquippedToHandsEvent>) -> EntityNotificationType {
    if Equals(this.m_wasIncapacitated, false) {
      switch evt.m_slot {
        case EHandEquipSlot.Left:
          this.m_leftHandLoadout = evt.m_itemID;
          break;
        case EHandEquipSlot.Right:
          this.m_rightHandLoadout = evt.m_itemID;
      };
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func DetermineInteractionState(interaction: ref<InteractionComponent>, context: GetActionsContext, objectActionsCallbackController: wref<gameObjectActionsCallbackController>) -> Void {
    let actionRecords: array<wref<ObjectAction_Record>>;
    let choices: array<InteractionChoice>;
    if !this.GetHudManager().IsQuickHackPanelOpened() {
      this.SetHasDirectInteractionChoicesActive(false);
      if !IsDefined(this.m_cooldownStorage) {
        this.m_cooldownStorage = new CooldownStorage();
        this.m_cooldownStorage.Initialize(this.GetID(), this.GetClassName(), this.GetGameInstance());
      };
      if !IsNameValid(context.interactionLayerTag) {
        context.interactionLayerTag = this.m_lastInteractionLayerTag;
      };
      if Equals(context.requestType, gamedeviceRequestType.Direct) {
        this.GetOwnerEntity().GetRecord().ObjectActions(actionRecords);
        this.GetValidChoices(actionRecords, context, objectActionsCallbackController, true, choices);
        if ArraySize(choices) > 0 {
          this.SetHasDirectInteractionChoicesActive(true);
        };
      };
    };
    this.PushChoicesToInteractionComponent(interaction, context, choices);
  }

  public final const func GetValidChoices(actions: array<wref<ObjectAction_Record>>, context: GetActionsContext, objectActionsCallbackController: wref<gameObjectActionsCallbackController>, checkPlayerQuickHackList: Bool, out choices: array<InteractionChoice>) -> Void {
    let actionList: array<TweakDBID>;
    let actionRecord: wref<ObjectAction_Record>;
    let actionType: gamedataObjectActionType;
    let choice: InteractionChoice;
    let choiceAdded: Bool;
    let compareAction: ref<PuppetAction>;
    let isQuickhack: Bool;
    let isRemote: Bool;
    let j: Int32;
    let puppetAction: ref<ScriptableDeviceAction>;
    let ownerEntity: wref<ScriptedPuppet> = this.GetOwnerEntity();
    let ownerIsActive: Bool = ScriptedPuppet.IsActive(ownerEntity);
    let instigator: wref<GameObject> = context.processInitiatorObject;
    let i: Int32 = 0;
    while i < ArraySize(actions) {
      choiceAdded = false;
      actionType = actions[i].ObjectActionType().Type();
      switch actionType {
        case gamedataObjectActionType.Payment:
        case gamedataObjectActionType.Item:
        case gamedataObjectActionType.Direct:
          isRemote = false;
          break;
        case gamedataObjectActionType.MinigameUpload:
        case gamedataObjectActionType.PuppetQuickHack:
        case gamedataObjectActionType.DeviceQuickHack:
        case gamedataObjectActionType.Remote:
          isRemote = true;
          break;
        default:
          isRemote = false;
      };
      if !isRemote && Equals(context.requestType, gamedeviceRequestType.Direct) || isRemote && Equals(context.requestType, gamedeviceRequestType.Remote) {
        actionRecord = actions[i];
        puppetAction = this.GetAction(actionRecord);
        puppetAction.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
        puppetAction.SetExecutor(instigator);
        puppetAction.CreateInteraction();
        puppetAction.SetObjectActionID(actions[i].GetID());
        puppetAction.SetUp(this);
        isQuickhack = puppetAction.IsQuickHack();
        if !isQuickhack {
          if !objectActionsCallbackController.HasObjectAction(actionRecord) {
            objectActionsCallbackController.AddObjectAction(actionRecord);
          };
        };
        if puppetAction.IsPossible(ownerEntity, objectActionsCallbackController) {
          if isQuickhack || puppetAction.IsVisible(context, objectActionsCallbackController) {
            if isQuickhack {
              if checkPlayerQuickHackList {
                if ArraySize(actionList) == 0 {
                  actionList = RPGManager.GetPlayerQuickHackList(GetPlayer(ownerEntity.GetGame()));
                };
                if !ArrayContains(actionList, actions[i].GetID()) {
                } else {
                  if !ownerIsActive {
                    puppetAction.SetInactiveWithReason(false, "LocKey#7018");
                  } else {
                    if !puppetAction.IsVisible(context) {
                      puppetAction.SetInactiveWithReason(false, "LocKey#7019");
                    };
                  };
                  choice = puppetAction.GetInteractionChoice();
                  ArrayPush(choice.data, ToVariant(puppetAction));
                  if !puppetAction.CanPayCost() {
                    ChoiceTypeWrapper.SetType(choice.choiceMetaData.type, gameinteractionsChoiceType.Inactive);
                  };
                  j = 0;
                  while j < ArraySize(choices) {
                    compareAction = FromVariant(choices[j].data[0]);
                    if IsDefined(compareAction) {
                      if actionRecord.Priority() >= compareAction.GetObjectActionRecord().Priority() {
                        ArrayInsert(choices, j, choice);
                        choiceAdded = true;
                      } else {
                        j += 1;
                      };
                    } else {
                    };
                    j += 1;
                  };
                  if !choiceAdded {
                    ArrayPush(choices, choice);
                  };
                };
              } else {
                if !ownerIsActive {
                  puppetAction.SetInactiveWithReason(false, "LocKey#7018");
                } else {
                  if !puppetAction.IsVisible(context) {
                    puppetAction.SetInactiveWithReason(false, "LocKey#7019");
                  };
                };
                choice = puppetAction.GetInteractionChoice();
                ArrayPush(choice.data, ToVariant(puppetAction));
                if !puppetAction.CanPayCost() {
                  ChoiceTypeWrapper.SetType(choice.choiceMetaData.type, gameinteractionsChoiceType.Inactive);
                };
                j = 0;
                while j < ArraySize(choices) {
                  compareAction = FromVariant(choices[j].data[0]);
                  if IsDefined(compareAction) {
                    if actionRecord.Priority() >= compareAction.GetObjectActionRecord().Priority() {
                      ArrayInsert(choices, j, choice);
                      choiceAdded = true;
                    } else {
                      j += 1;
                    };
                  } else {
                  };
                  j += 1;
                };
                if !choiceAdded {
                  ArrayPush(choices, choice);
                };
              };
            } else {
              choice = puppetAction.GetInteractionChoice();
              ArrayPush(choice.data, ToVariant(puppetAction));
              if !puppetAction.CanPayCost() {
                ChoiceTypeWrapper.SetType(choice.choiceMetaData.type, gameinteractionsChoiceType.Inactive);
              };
              j = 0;
              while j < ArraySize(choices) {
                compareAction = FromVariant(choices[j].data[0]);
                if IsDefined(compareAction) {
                  if actionRecord.Priority() >= compareAction.GetObjectActionRecord().Priority() {
                    ArrayInsert(choices, j, choice);
                    choiceAdded = true;
                  } else {
                    j += 1;
                  };
                } else {
                };
                j += 1;
              };
              if !choiceAdded {
                ArrayPush(choices, choice);
              };
            };
          } else {
            puppetAction.SetInactiveWithReason(false, "LocKey#7009");
          };
        };
      };
      i += 1;
    };
  }

  protected final const func GetAction(actionRecord: wref<ObjectAction_Record>) -> ref<PuppetAction> {
    let breachAction: ref<AccessBreach>;
    let isPhysicalBreach: Bool;
    let isRemoteBreach: Bool;
    let isSuicideBreach: Bool;
    let puppetAction: ref<PuppetAction>;
    if !IsDefined(actionRecord) {
      return null;
    };
    isRemoteBreach = Equals(actionRecord.ActionName(), n"RemoteBreach");
    isSuicideBreach = Equals(actionRecord.ActionName(), n"SuicideBreach");
    isPhysicalBreach = Equals(actionRecord.ActionName(), n"PhysicalBreach");
    if isPhysicalBreach || isRemoteBreach || isSuicideBreach {
      breachAction = new AccessBreach();
      if this.IsConnectedToAccessPoint() {
        breachAction.SetProperties(this.GetNetworkName(), this.GetNPCsConnectedToThisAPCount(), this.GetAccessPoint().GetMinigameAttempt(), isRemoteBreach, isSuicideBreach);
      } else {
        breachAction.SetProperties("SQUAD_NETWORK", 1, 1, isRemoteBreach, isSuicideBreach);
      };
      puppetAction = breachAction;
    } else {
      if Equals(actionRecord.ActionName(), n"Ping") {
        puppetAction = new PingSquad();
      } else {
        puppetAction = new PuppetAction();
      };
    };
    return puppetAction;
  }

  public final const func GetAllChoices(actions: array<wref<ObjectAction_Record>>, context: GetActionsContext, out puppetActions: array<ref<PuppetAction>>) -> Void {
    let actionType: gamedataObjectActionType;
    let isRemote: Bool;
    let puppetAction: ref<PuppetAction>;
    let isBreached: Bool = this.IsBreached();
    let isQuickHackExposed: Bool = this.IsQuickHacksExposed();
    let attiudeTowardsPlayer: EAIAttitude = this.GetOwnerEntity().GetAttitudeTowards(GetPlayer(this.GetGameInstance()));
    let isPuppetActive: Bool = ScriptedPuppet.IsActive(this.GetOwnerEntity());
    let instigator: wref<GameObject> = context.processInitiatorObject;
    let i: Int32 = 0;
    while i < ArraySize(actions) {
      actionType = actions[i].ObjectActionType().Type();
      switch actionType {
        case gamedataObjectActionType.Payment:
        case gamedataObjectActionType.Item:
        case gamedataObjectActionType.Direct:
          isRemote = false;
          break;
        case gamedataObjectActionType.MinigameUpload:
        case gamedataObjectActionType.PuppetQuickHack:
        case gamedataObjectActionType.DeviceQuickHack:
        case gamedataObjectActionType.Remote:
          isRemote = true;
          break;
        default:
          isRemote = false;
      };
      if isRemote && Equals(context.requestType, gamedeviceRequestType.Remote) {
        if !TweakDBInterface.GetBool(actions[i].GetID() + t".isQuickHack", false) {
        } else {
          puppetAction = this.GetAction(actions[i]);
          puppetAction.SetExecutor(instigator);
          puppetAction.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
          puppetAction.SetObjectActionID(actions[i].GetID());
          puppetAction.SetUp(this);
          if puppetAction.IsQuickHack() {
            if (puppetAction as AccessBreach) != null && isBreached {
              puppetAction.SetInactiveWithReason(!isBreached, "LocKey#27728");
            } else {
              if !isQuickHackExposed && (puppetAction as AccessBreach) == null {
                if NotEquals(attiudeTowardsPlayer, EAIAttitude.AIA_Friendly) {
                  puppetAction.SetInactiveWithReason(false, "LocKey#7017");
                } else {
                  puppetAction.SetInactiveWithReason(false, "LocKey#27694");
                };
              } else {
                if !isPuppetActive {
                  puppetAction.SetInactiveWithReason(false, "LocKey#7018");
                };
              };
            };
            ArrayPush(puppetActions, puppetAction);
          };
        };
      };
      i += 1;
    };
  }

  public final static func RemoveDuplicatedChoices(choices: script_ref<array<InteractionChoice>>) -> Void {
    let i2: Int32;
    let i: Int32 = ArraySize(Deref(choices)) - 1;
    while i >= 0 {
      i2 = 0;
      while i2 < ArraySize(Deref(choices)) {
        if i2 == i {
        } else {
          if Deref(choices)[i].choiceMetaData.tweakDBID == Deref(choices)[i2].choiceMetaData.tweakDBID {
            ArrayErase(Deref(choices), i);
          } else {
            i2 += 1;
          };
        };
      };
      i -= 1;
    };
  }

  private final func PushChoicesToInteractionComponent(interactionComponent: ref<InteractionComponent>, context: GetActionsContext, choices: script_ref<array<InteractionChoice>>) -> Void {
    let shouldPushChoices: Bool;
    let maxDirectChoices: Int32 = 4;
    if IsNameValid(context.interactionLayerTag) {
      interactionComponent.ResetChoices(context.interactionLayerTag);
    } else {
      interactionComponent.ResetChoices();
    };
    if ArraySize(Deref(choices)) == 0 {
      return;
    };
    switch context.requestType {
      case gamedeviceRequestType.Direct:
        shouldPushChoices = true;
        if ArraySize(Deref(choices)) > maxDirectChoices {
          ArrayResize(Deref(choices), maxDirectChoices);
        };
        break;
      default:
        if !IsFinal() {
          LogDevices(this, "Unsupported request source - potential errors", ELogType.WARNING);
        };
    };
    if shouldPushChoices {
      if Equals(context.interactionLayerTag, n"AerialTakedown") {
        this.PushAerialTakedownActionEventToPSM(this.GetOwnerEntity());
      } else {
        interactionComponent.SetChoices(Deref(choices), context.interactionLayerTag);
      };
      this.m_lastInteractionLayerTag = context.interactionLayerTag;
    };
  }

  private final func PushAerialTakedownActionEventToPSM(target: wref<GameObject>) -> Void {
    let takedownAction: ref<PuppetAction>;
    let takedownEvent: ref<StartTakedownEvent> = new StartTakedownEvent();
    let player: ref<PlayerPuppet> = this.GetPlayerMainObject() as PlayerPuppet;
    takedownEvent.slideTime = 0.30;
    takedownEvent.target = target;
    takedownEvent.actionName = n"LeapToTarget";
    player.QueueEvent(takedownEvent);
    takedownAction = new PuppetAction();
    takedownAction.RegisterAsRequester(target.GetEntityID());
    takedownAction.SetExecutor(player);
    takedownAction.SetObjectActionID(t"Takedown.AerialTakedown");
    takedownAction.SetUp(this);
    takedownAction.ProcessRPGAction(target.GetGame());
  }

  public func GenerateContext(requestType: gamedeviceRequestType, providedClearance: ref<Clearance>, opt providedProcessInitiator: ref<GameObject>, opt providedRequestor: EntityID) -> GetActionsContext {
    let generatedContext: GetActionsContext;
    generatedContext.clearance = providedClearance;
    if EntityID.IsDefined(providedRequestor) {
      generatedContext.requestorID = providedRequestor;
    } else {
      generatedContext.requestorID = PersistentID.ExtractEntityID(this.GetID());
    };
    generatedContext.requestType = requestType;
    if Equals(requestType, gamedeviceRequestType.Remote) {
      generatedContext.interactionLayerTag = n"remote";
    } else {
      if Equals(requestType, gamedeviceRequestType.Direct) {
        generatedContext.interactionLayerTag = n"direct";
      };
    };
    if IsDefined(providedProcessInitiator) {
      generatedContext.processInitiatorObject = providedProcessInitiator;
    } else {
      if this.GetOwnerEntity().IsPlayerAround() {
        generatedContext.processInitiatorObject = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject();
      };
    };
    return generatedContext;
  }

  public final func OnObjectAction(evt: ref<ScriptableDeviceAction>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final static func ActionSecurityBreachNotificationStatic(lastKnownPosition: Vector4, whoBreached: ref<GameObject>, reporterHandle: wref<GameObject>, type: ESecurityNotificationType) -> ref<SecuritySystemInput> {
    let canPerformReprimand: Bool;
    let action: ref<SecuritySystemInput> = new SecuritySystemInput();
    if IsDefined(whoBreached) {
      canPerformReprimand = true;
    } else {
      canPerformReprimand = false;
    };
    action.SetProperties(lastKnownPosition, whoBreached, reporterHandle.GetDeviceLink(), type, canPerformReprimand, false);
    action.AddDeviceName("DebugNPC");
    return action;
  }

  public final const func CheckFlatheadTakedownAvailability(context: GetActionsContext) -> Bool {
    let attitudeTowardsPlayer: EAIAttitude;
    let flathead: wref<GameObject>;
    let navigationPath: ref<NavigationPath>;
    let owner: wref<ScriptedPuppet> = this.GetOwnerEntity();
    if !SubCharacterSystem.GetInstance(owner.GetGame()).IsFlatheadFollowing() {
      return false;
    };
    if !owner.IsAggressive() {
      return false;
    };
    attitudeTowardsPlayer = owner.GetAttitudeAgent().GetAttitudeTowards(context.processInitiatorObject.GetAttitudeAgent());
    if Equals(attitudeTowardsPlayer, EAIAttitude.AIA_Friendly) {
      return false;
    };
    if !AIActionHelper.CheckFlatheadStatPoolRequirements(owner.GetGame(), "Takedown") {
      return false;
    };
    flathead = (GameInstance.GetScriptableSystemsContainer(owner.GetGame()).Get(n"SubCharacterSystem") as SubCharacterSystem).GetFlathead();
    navigationPath = GameInstance.GetAINavigationSystem(owner.GetGame()).CalculatePathForCharacter(flathead.GetWorldPosition(), owner.GetWorldPosition(), 0.50, owner);
    if navigationPath == null {
      return false;
    };
    return true;
  }

  public final func OnSetExposeQuickHacks(evt: ref<SetExposeQuickHacks>) -> EntityNotificationType {
    let i: Int32;
    let j: Int32;
    let lootMaterialsID: TweakDBID;
    let lootMoneyID: TweakDBID;
    let lootShardID: TweakDBID;
    let networkAction: ref<PuppetAction>;
    let puppetActions: array<wref<ObjectAction_Record>>;
    let TS: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetOwnerEntity().GetGame());
    let minigameBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetOwnerEntity().GetGame()).Get(GetAllBlackboardDefs().HackingMinigame);
    let minigamePrograms: array<TweakDBID> = FromVariant(minigameBB.GetVariant(GetAllBlackboardDefs().HackingMinigame.ActivePrograms));
    let activeTraps: array<TweakDBID> = FromVariant(minigameBB.GetVariant(GetAllBlackboardDefs().HackingMinigame.ActiveTraps));
    if IsDefined(minigameBB) {
      if ArraySize(minigamePrograms) > 0 {
        this.m_isBreached = true;
      };
      if ArraySize(minigamePrograms) < 3 {
        if Cast(GameInstance.GetStatsSystem(this.GetPlayerMainObject().GetGame()).GetStatValue(Cast(this.GetPlayerMainObject().GetEntityID()), gamedataStatType.MinigameNextInstanceBufferExtensionPerk)) {
          (this.GetPlayerMainObject() as PlayerPuppet).SetBufferModifier(ArraySize(minigamePrograms));
        };
      } else {
        if ArraySize(minigamePrograms) >= 3 {
          if GameInstance.GetStatsSystem(this.GetPlayerMainObject().GetGame()).GetStatValue(Cast(this.GetPlayerMainObject().GetEntityID()), gamedataStatType.ThreeOrMoreProgramsMemoryRegPerk) == 1.00 {
            StatusEffectHelper.ApplyStatusEffect(this.GetPlayerMainObject(), t"BaseStatusEffect.ThreeOrMoreProgramsMemoryRegPerk1", this.GetPlayerMainObject().GetEntityID());
          };
          if GameInstance.GetStatsSystem(this.GetPlayerMainObject().GetGame()).GetStatValue(Cast(this.GetPlayerMainObject().GetEntityID()), gamedataStatType.ThreeOrMoreProgramsMemoryRegPerk) == 2.00 {
            StatusEffectHelper.ApplyStatusEffect(this.GetPlayerMainObject(), t"BaseStatusEffect.ThreeOrMoreProgramsMemoryRegPerk2", this.GetPlayerMainObject().GetEntityID());
          };
          if Cast(GameInstance.GetStatsSystem(this.GetPlayerMainObject().GetGame()).GetStatValue(Cast(this.GetPlayerMainObject().GetEntityID()), gamedataStatType.ThreeOrMoreProgramsCooldownRedPerk)) {
            StatusEffectHelper.ApplyStatusEffect(this.GetPlayerMainObject(), t"BaseStatusEffect.ThreeOrMoreProgramsCooldownRedPerk", this.GetPlayerMainObject().GetEntityID());
          };
          if Cast(GameInstance.GetStatsSystem(this.GetPlayerMainObject().GetGame()).GetStatValue(Cast(this.GetPlayerMainObject().GetEntityID()), gamedataStatType.MinigameNextInstanceBufferExtensionPerk)) {
            (this.GetPlayerMainObject() as PlayerPuppet).SetBufferModifier(3);
          };
        };
      };
      TweakDBInterface.GetCharacterRecord(this.GetOwnerEntity().GetRecordID()).ObjectActions(puppetActions);
      lootShardID = t"MinigameAction.NetworkLootShard";
      lootMaterialsID = t"MinigameAction.NetworkLootMaterials";
      lootMoneyID = t"MinigameAction.NetworkLootMoney";
      j = 0;
      while j < ArraySize(activeTraps) {
        if activeTraps[j] == t"MinigameTraps.MaterialBonus" {
          TS.GiveItemByItemQuery(this.GetPlayerMainObject(), t"Query.QuickHackMaterial", 1u);
        } else {
          if activeTraps[j] == t"MinigameTraps.SquadBuff" {
            StatusEffectHelper.ApplyStatusEffect(this.GetOwnerEntity(), t"MinigameAction.BuffDamageReductionMinigame", this.GetPlayerMainObject().GetEntityID());
          };
        };
        j += 1;
      };
      i = 0;
      while i < ArraySize(minigamePrograms) {
        if minigamePrograms[i] == lootShardID {
          TS.GiveItemByItemQuery(this.GetPlayerMainObject(), t"Query.CombatCyberdeckProgram");
        } else {
          if minigamePrograms[i] == lootMaterialsID {
            TS.GiveItemByItemQuery(this.GetPlayerMainObject(), t"Query.QuickHackMaterial", 3u);
          } else {
            if minigamePrograms[i] == lootMoneyID {
              RPGManager.GiveReward(this.GetPlayerMainObject().GetGame(), t"QuestRewards.MinigameMoney", Cast(this.GetOwnerEntity().GetEntityID()));
            };
          };
        };
        this.FilterRedundantPrograms(minigamePrograms);
        j = 0;
        while j < ArraySize(puppetActions) {
          if puppetActions[j].GetID() == minigamePrograms[i] {
            networkAction = new PuppetAction();
            networkAction.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
            networkAction.SetExecutor(this.GetPlayerMainObject());
            networkAction.SetObjectActionID(minigamePrograms[i]);
            networkAction.SetUp(this);
            networkAction.ProcessRPGAction(this.GetGameInstance());
          };
          j += 1;
        };
        i += 1;
      };
    };
    this.ForceExposeQuickHack(true);
    this.CheckMasterRunnerAchievement(ArraySize(minigamePrograms));
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func FilterRedundantPrograms(out programs: array<TweakDBID>) -> Void {
    if ArrayContains(programs, t"MinigameAction.NetworkTurretShutdown") && ArrayContains(programs, t"MinigameAction.NetworkTurretFriendly") {
      ArrayRemove(programs, t"MinigameAction.NetworkTurretShutdown");
    };
  }

  private final func ForceExposeQuickHack(shouldForce: Bool) -> Void {
    this.m_quickHacksExposed = shouldForce;
  }

  public final const func IsActionReady(actionID: TweakDBID) -> Bool {
    return this.m_cooldownStorage.IsActionReady(actionID);
  }

  public final func OnActionCooldownEvent(evt: ref<ActionCooldownEvent>) -> EntityNotificationType {
    this.m_cooldownStorage.ResolveCooldownEvent(evt);
    this.GetPlayerCooldownStorage().ResolveCooldownEvent(evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func ManuallyTriggerActionCooldown(actionID: TweakDBID) -> Void {
    this.m_cooldownStorage.ManuallyTriggerCooldown(actionID);
  }

  protected final func ActionSetExposeQuickHacks() -> ref<SetExposeQuickHacks> {
    let action: ref<SetExposeQuickHacks> = new SetExposeQuickHacks();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName("NPC Hijack action");
    return action;
  }

  public final const func GetNumberActions() -> Int32 {
    return this.m_numberActions;
  }

  public final const func HasActiveContext(context: gamedeviceRequestType) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_activeContexts) {
      if Equals(this.m_activeContexts[i], context) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func AddActiveContext(context: gamedeviceRequestType) -> Void {
    if !this.HasActiveContext(context) {
      ArrayPush(this.m_activeContexts, context);
    };
  }

  public final func RemoveActiveContext(context: gamedeviceRequestType) -> Void {
    let i: Int32 = ArraySize(this.m_activeContexts) - 1;
    while i >= 0 {
      if Equals(this.m_activeContexts[i], context) {
        ArrayErase(this.m_activeContexts, i);
      } else {
        i -= 1;
      };
    };
  }

  public final func SetReactionPresetID(presetID: TweakDBID) -> Void {
    this.m_reactionPresetID = presetID;
  }

  public final const func GetReactionPresetID() -> TweakDBID {
    return this.m_reactionPresetID;
  }

  public final const func IsDefeatMechanicActive() -> Bool {
    return this.m_isDefeatMechanicActive;
  }

  public final func SetIsDefeatMechanicActive(isDefeatMechanicActive: Bool) -> Void {
    this.m_isDefeatMechanicActive = isDefeatMechanicActive;
  }

  protected final const func CheckMasterRunnerAchievement(minigameProgramsCompleted: Int32) -> Void {
    let achievementRequest: ref<AddAchievementRequest>;
    let achievement: gamedataAchievement = gamedataAchievement.MasterRunner;
    let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"DataTrackingSystem") as DataTrackingSystem;
    if dataTrackingSystem.IsAchievementUnlocked(achievement) {
      return;
    };
    if minigameProgramsCompleted >= 3 {
      achievementRequest = new AddAchievementRequest();
      achievementRequest.achievement = achievement;
      dataTrackingSystem.QueueRequest(achievementRequest);
    };
  }

  public final func SetIsDead(isDead: Bool) -> Void {
    this.m_isDead = isDead;
  }

  public final const func GetIsDead() -> Bool {
    return this.m_isDead;
  }

  public final func SetIsIncapacitated(isIncapacitated: Bool) -> Void {
    this.m_isIncapacitated = isIncapacitated;
  }

  public final const func GetIsIncapacitated() -> Bool {
    return this.m_isIncapacitated;
  }

  public final func SetIsAndroidTurnedOff(isAndroidTurnedOff: Bool) -> Void {
    this.m_isAndroidTurnedOff = isAndroidTurnedOff;
  }

  public final const func GetIsAndroidTurnedOff() -> Bool {
    return this.m_isAndroidTurnedOff;
  }

  protected final const func GetHudManager() -> ref<HUDManager> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"HUDManager") as HUDManager;
  }

  protected final func OnTargetAssessmentRequest(evt: ref<TargetAssessmentRequest>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func OnPingSquad(evt: ref<PingSquad>) -> EntityNotificationType {
    let request: ref<ClearPingedSquadRequest>;
    if evt.ShouldForward() {
      if evt.GetRequesterID() == this.GetMyEntityID() {
        request = new ClearPingedSquadRequest();
        GameInstance.QueueScriptableSystemRequest(this.GetGameInstance(), n"NetworkSystem", request);
      };
      this.GetDeviceLink().PingDevicesNetwork();
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }
}

public static exec func CheatExposeNPCQuickHacks(gameInstance: GameInstance) -> Void {
  SetFactValue(gameInstance, n"cheat_expose_npc_quick_hacks", 1);
}
