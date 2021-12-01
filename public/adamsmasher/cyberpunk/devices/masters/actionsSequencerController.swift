
public class ActionsSequencerController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ActionsSequencerControllerPS extends MasterControllerPS {

  @attrib(tooltip, "IMPORTANT: DON'T MAKE THIS VALUE TOO HIGH AS ALL QUICK HACKS ARE BLOCKED UNTIL THIS TIMES PASSES. Time when the last device connected to ActionSequencer will receive the forwarded action. If 0.0 then sequenceMode is forced to AT_THE_SAME_TIME")
  @default(ActionsSequencerControllerPS, 2f)
  private let m_sequenceDuration: Float;

  @attrib(tooltip, "Immediate - all devices receive actins immediately, REGULAR - Max Sequence Duration will be divided by the number of devices. Each consecutive device receives event after the same amount of time, ACCELERATING - start slow, end fast DECELARTING - start fast end slow, RANDOM - random")
  private let m_sequencerMode: EActionsSequencerMode;

  @attrib(tooltip, "Filter actions by source of action. There can be more than 1 srespected source")
  private let m_actionTypeToForward: SActionTypeForward;

  private let m_ongoingSequence: ActionsSequence;

  protected func Initialize() -> Void {
    if this.m_sequenceDuration == 0.00 {
      this.m_sequencerMode = EActionsSequencerMode.AT_THE_SAME_TIME_TODO;
    };
    this.m_sequencerMode = EActionsSequencerMode.REGULAR_INTERVALS;
    this.Initialize();
  }

  private final func OnForwardAction(evt: ref<ForwardAction>) -> EntityNotificationType {
    let eligibleSlaves: array<ref<DeviceComponentPS>>;
    if !this.IsActionTypeMachingPreferences(evt) {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    eligibleSlaves = this.GetEligibleSlaves(evt.requester);
    if ArraySize(eligibleSlaves) <= 1 {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    if this.IsSequenceOngoing() {
      if !IsFinal() {
        LogDevices(this, "Multiple simultanous sequences are not handled", ELogType.WARNING);
      };
      return EntityNotificationType.DoNotNotifyEntity;
    };
    if IsDefined(evt.actionToForward) {
      this.CommenceSequence(evt.actionToForward, eligibleSlaves, this.GetDelayTimeStamps(ArraySize(eligibleSlaves)));
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func IsActionTypeMachingPreferences(forwardEvent: ref<ForwardAction>) -> Bool {
    if forwardEvent.actionToForward.IsQuickHack() && this.m_actionTypeToForward.qHack {
      return true;
    };
    if forwardEvent.actionToForward.IsSpiderbotAction() && this.m_actionTypeToForward.techie {
      return true;
    };
    if this.WasExecutedByMaster(forwardEvent) && this.m_actionTypeToForward.master {
      return true;
    };
    return false;
  }

  private final func WasExecutedByMaster(forwardEvent: ref<ForwardAction>) -> Bool {
    return PersistentID.ExtractEntityID(forwardEvent.requester) != forwardEvent.actionToForward.GetRequesterID();
  }

  private final func CommenceSequence(actionToForward: ref<ScriptableDeviceAction>, eligibleSlaves: array<ref<DeviceComponentPS>>, delays: array<Float>) -> Void {
    let i: Int32;
    let sequenceCallback: ref<SequenceCallback>;
    let delaySystem: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGameInstance());
    if !IsDefined(delaySystem) {
      if !IsFinal() {
        LogDevices(this, "NO DELAY SYSTEM! Sequence not started", ELogType.ERROR);
      };
      return;
    };
    this.m_ongoingSequence.sequenceInitiator = actionToForward.GetRequesterID();
    this.m_ongoingSequence.maxActionsInSequence = ArraySize(eligibleSlaves);
    this.m_ongoingSequence.actionsTriggeredCount = 0;
    this.ForceLockOnAllSlaves();
    if Equals(this.m_sequencerMode, EActionsSequencerMode.AT_THE_SAME_TIME_TODO) {
    } else {
      if ArraySize(eligibleSlaves) != ArraySize(delays) {
        if !IsFinal() {
          LogDevices(this, "delays size and devices size is not the same - debug", ELogType.ERROR);
        };
        return;
      };
      i = 0;
      while i < ArraySize(delays) {
        sequenceCallback = new SequenceCallback();
        sequenceCallback.persistentID = eligibleSlaves[i].GetID();
        sequenceCallback.className = eligibleSlaves[i].GetClassName();
        sequenceCallback.actionToForward = actionToForward;
        ArrayPush(this.m_ongoingSequence.delayIDs, delaySystem.DelayPSEvent(this.GetID(), this.GetClassName(), sequenceCallback, delays[i]));
        i += 1;
      };
    };
  }

  public final func OnSequenceCallback(evt: ref<SequenceCallback>) -> EntityNotificationType {
    this.m_ongoingSequence.actionsTriggeredCount += 1;
    this.GetPersistencySystem().QueuePSEvent(evt.persistentID, evt.className, evt.actionToForward);
    this.ForceUnlockSlave(evt.persistentID, evt.className);
    if this.m_ongoingSequence.actionsTriggeredCount == this.m_ongoingSequence.maxActionsInSequence - 1 {
      this.CleanupSequence();
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final const func ForceUnlockSlave(persistentID: PersistentID, className: CName) -> Void {
    let unlockDevice: ref<SequencerLock> = new SequencerLock();
    unlockDevice.shouldLock = false;
    GameInstance.GetDelaySystem(this.GetGameInstance()).DelayPSEvent(persistentID, className, unlockDevice, 0.10);
  }

  private final const func ForceLockOnAllSlaves() -> Void {
    let lock: ref<SequencerLock> = new SequencerLock();
    lock.shouldLock = true;
    let eligibleSlaves: array<ref<DeviceComponentPS>> = this.GetEligibleSlaves(Cast(this.m_ongoingSequence.sequenceInitiator));
    let i: Int32 = 0;
    while i < ArraySize(eligibleSlaves) {
      this.GetPersistencySystem().QueuePSEvent(eligibleSlaves[i].GetID(), eligibleSlaves[i].GetClassName(), lock);
      i += 1;
    };
  }

  private final func CleanupSequence() -> Void {
    let emptyID: EntityID;
    this.m_ongoingSequence.sequenceInitiator = emptyID;
    this.m_ongoingSequence.maxActionsInSequence = 0;
    this.m_ongoingSequence.actionsTriggeredCount = 0;
    ArrayClear(this.m_ongoingSequence.delayIDs);
  }

  private final const func GetEligibleSlaves(sequenceInitiator: PersistentID) -> array<ref<DeviceComponentPS>> {
    let fallbackArray: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let slaves: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    if Equals(sequenceInitiator, this.GetID()) {
      return slaves;
    };
    i = 0;
    while i < ArraySize(slaves) {
      if Equals(slaves[i].GetID(), sequenceInitiator) {
        ArrayErase(slaves, i);
        return slaves;
      };
      i += 1;
    };
    if !IsFinal() {
      LogDevices(this, "SequenceInitiator not found in the list of slaves - someone hacked something. Debug", ELogType.ERROR);
    };
    return fallbackArray;
  }

  private final const func GetDelayTimeStamps(intervals: Int32) -> array<Float> {
    let delays: array<Float>;
    switch this.m_sequencerMode {
      case EActionsSequencerMode.REGULAR_INTERVALS:
        this.GetRegularDelays(intervals, delays);
        break;
      case EActionsSequencerMode.ACCELERATING_INTERVALS_TODO:
        this.GetAcceleratingDelays(intervals, delays);
        break;
      case EActionsSequencerMode.DECELERATING_INTEVALS_TODO:
        this.GetDecceleratingDelays(intervals, delays);
        break;
      case EActionsSequencerMode.RANDOM_INTERVALS_TODO:
        this.GetRandomDelays(intervals, delays);
        break;
      case EActionsSequencerMode.AT_THE_SAME_TIME_TODO:
        ArrayPush(delays, this.m_sequenceDuration);
        break;
      default:
        if !IsFinal() {
          LogDevices(this, "Wrong Sequence Mode debug. Using Regular mode");
        };
    };
    this.GetRegularDelays(intervals, delays);
    return delays;
  }

  private final const func GetRegularDelays(amountOfIntervals: Int32, out delays: array<Float>) -> Void {
    let interval: Float = this.m_sequenceDuration / Cast(amountOfIntervals);
    let i: Int32 = 1;
    while i < amountOfIntervals + 1 {
      ArrayPush(delays, interval * Cast(i));
      i += 1;
    };
  }

  private final const func GetAcceleratingDelays(amountOfIntervals: Int32, out delays: array<Float>) -> Void;

  private final const func GetDecceleratingDelays(amountOfIntervals: Int32, out delays: array<Float>) -> Void;

  private final const func GetRandomDelays(amountOfIntervals: Int32, out delays: array<Float>) -> Void;

  private final const func IsSequenceOngoing() -> Bool {
    if this.m_ongoingSequence.maxActionsInSequence > 0 {
      return true;
    };
    return false;
  }

  public func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    if Clearance.IsInRange(context.clearance, DefaultActionsParametersHolder.GetQuestClearance()) {
      ArrayPush(outActions, this.ActionQuestForcePower());
      ArrayPush(outActions, this.ActionQuestForceUnpower());
      ArrayPush(outActions, this.ActionQuestForceON());
      ArrayPush(outActions, this.ActionQuestForceOFF());
      ArrayPush(outActions, this.ActionActivateDevice());
      ArrayPush(outActions, this.ActionDeactivateDevice());
    };
    return;
  }

  protected func OnQuestForceOFF(evt: ref<QuestForceOFF>) -> EntityNotificationType {
    let forwarder: ref<ForwardAction> = new ForwardAction();
    forwarder.requester = this.GetID();
    forwarder.actionToForward = evt;
    this.OnForwardAction(forwarder);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnQuestForceON(evt: ref<QuestForceON>) -> EntityNotificationType {
    let forwarder: ref<ForwardAction> = new ForwardAction();
    forwarder.requester = this.GetID();
    forwarder.actionToForward = evt;
    this.OnForwardAction(forwarder);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnQuestForceUnpower(evt: ref<QuestForceUnpower>) -> EntityNotificationType {
    let forwarder: ref<ForwardAction> = new ForwardAction();
    forwarder.requester = this.GetID();
    forwarder.actionToForward = evt;
    this.OnForwardAction(forwarder);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnQuestForcePower(evt: ref<QuestForcePower>) -> EntityNotificationType {
    let forwarder: ref<ForwardAction> = new ForwardAction();
    forwarder.requester = this.GetID();
    forwarder.actionToForward = evt;
    this.OnForwardAction(forwarder);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnSetDeviceON(evt: ref<SetDeviceON>) -> EntityNotificationType {
    let forwarder: ref<ForwardAction> = new ForwardAction();
    forwarder.requester = this.GetID();
    forwarder.actionToForward = evt;
    this.OnForwardAction(forwarder);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnSetDeviceOFF(evt: ref<SetDeviceOFF>) -> EntityNotificationType {
    let forwarder: ref<ForwardAction> = new ForwardAction();
    forwarder.requester = this.GetID();
    forwarder.actionToForward = evt;
    this.OnForwardAction(forwarder);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnSetDevicePowered(evt: ref<SetDevicePowered>) -> EntityNotificationType {
    let forwarder: ref<ForwardAction> = new ForwardAction();
    forwarder.requester = this.GetID();
    forwarder.actionToForward = evt;
    this.OnForwardAction(forwarder);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnSetDeviceUnpowered(evt: ref<SetDeviceUnpowered>) -> EntityNotificationType {
    let forwarder: ref<ForwardAction> = new ForwardAction();
    forwarder.requester = this.GetID();
    forwarder.actionToForward = evt;
    this.OnForwardAction(forwarder);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnActivateDevice(evt: ref<ActivateDevice>) -> EntityNotificationType {
    let forwarder: ref<ForwardAction> = new ForwardAction();
    forwarder.requester = this.GetID();
    forwarder.actionToForward = evt;
    this.OnForwardAction(forwarder);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnDeactivateDevice(evt: ref<DeactivateDevice>) -> EntityNotificationType {
    let forwarder: ref<ForwardAction> = new ForwardAction();
    forwarder.requester = this.GetID();
    forwarder.actionToForward = evt;
    this.OnForwardAction(forwarder);
    return EntityNotificationType.DoNotNotifyEntity;
  }
}
