
public abstract class UpperBodyTransition extends DefaultTransition {

  protected final const func EmptyHandsCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsInSafeSceneTier(scriptInterface) && (Equals(scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneAimForced), true) || Equals(scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneSafeForced), true)) {
      return false;
    };
    if scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.UseUnarmed) {
      return true;
    };
    if DefaultTransition.HasRightWeaponEquipped(scriptInterface) && stateContext.GetBoolParameter(n"requestWeaponUnequip", false) {
      return true;
    };
    return false;
  }

  protected final const func GetTransactionSystem(const scriptInterface: ref<StateGameScriptInterface>) -> ref<TransactionSystem> {
    let transactionSystem: ref<TransactionSystem> = scriptInterface.GetTransactionSystem();
    if !IsDefined(transactionSystem) {
      return null;
    };
    return transactionSystem;
  }

  public final static func HasLeftWeaponEquipped(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if IsDefined(scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponLeft") as WeaponObject) {
      return true;
    };
    return false;
  }

  public final static func HasAnyWeaponEquipped(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if UpperBodyTransition.HasLeftWeaponEquipped(scriptInterface) || DefaultTransition.HasRightWeaponEquipped(scriptInterface) {
      return true;
    };
    return false;
  }

  public final static func HasMeleeWeaponEquipped(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weapon: ref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
    if IsDefined(weapon) {
      if scriptInterface.GetTransactionSystem().HasTag(scriptInterface.executionOwner, WeaponObject.GetMeleeWeaponTag(), weapon.GetItemID()) {
        return true;
      };
    };
    return false;
  }

  public final static func HasRangedWeaponEquipped(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weapon: ref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
    if IsDefined(weapon) {
      if scriptInterface.GetTransactionSystem().HasTag(scriptInterface.executionOwner, WeaponObject.GetRangedWeaponTag(), weapon.GetItemID()) {
        return true;
      };
    };
    return false;
  }

  public final static func HasMeleewareEquipped(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weapon: ref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
    if IsDefined(weapon) {
      if scriptInterface.GetTransactionSystem().HasTag(scriptInterface.executionOwner, n"Meleeware", weapon.GetItemID()) {
        return true;
      };
    };
    return false;
  }

  protected final func IsItemMeleeware(item: ItemID) -> Bool {
    let itemTags: array<CName> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item)).Tags();
    return ArrayContains(itemTags, n"Meleeware");
  }

  public final func StopEffectOnHeldItems(scriptInterface: ref<StateGameScriptInterface>, effectName: CName) -> Void {
    let leftItem: ref<ItemObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponLeft");
    let rightItem: ref<ItemObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight");
    let killEffectEvent: ref<entKillEffectEvent> = new entKillEffectEvent();
    killEffectEvent.effectName = effectName;
    if IsDefined(leftItem) {
      leftItem.QueueEventToChildItems(killEffectEvent);
    };
    if IsDefined(rightItem) {
      rightItem.QueueEventToChildItems(killEffectEvent);
    };
  }

  public final func BreakEffectLoopOnHeldItems(scriptInterface: ref<StateGameScriptInterface>, effectName: CName) -> Void {
    let leftItem: ref<ItemObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponLeft");
    let rightItem: ref<ItemObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight");
    let BreakEffectLoopEvent: ref<entBreakEffectLoopEvent> = new entBreakEffectLoopEvent();
    BreakEffectLoopEvent.effectName = effectName;
    if IsDefined(leftItem) {
      leftItem.QueueEventToChildItems(BreakEffectLoopEvent);
    };
    if IsDefined(rightItem) {
      rightItem.QueueEventToChildItems(BreakEffectLoopEvent);
    };
  }

  protected final func SendDOFData(scriptInterface: ref<StateGameScriptInterface>, dofSetting: String) -> Void {
    let dofAnimFeature: ref<AnimFeature_DOFControl> = new AnimFeature_DOFControl();
    let prefix: String = "player." + dofSetting + ".";
    dofAnimFeature.dofIntensity = TweakDBInterface.GetFloat(TDBID.Create(prefix + "intensity"), 0.00);
    dofAnimFeature.dofNearBlur = TweakDBInterface.GetFloat(TDBID.Create(prefix + "nearBlur"), -1.00);
    dofAnimFeature.dofNearFocus = TweakDBInterface.GetFloat(TDBID.Create(prefix + "nearFocus"), -1.00);
    dofAnimFeature.dofFarBlur = TweakDBInterface.GetFloat(TDBID.Create(prefix + "farBlur"), -1.00);
    dofAnimFeature.dofFarFocus = TweakDBInterface.GetFloat(TDBID.Create(prefix + "farFocus"), -1.00);
    dofAnimFeature.dofBlendInTime = TweakDBInterface.GetFloat(TDBID.Create(prefix + "dofBlendInTime"), -1.00);
    dofAnimFeature.dofBlendOutTime = TweakDBInterface.GetFloat(TDBID.Create(prefix + "dofBlendOutTime"), -1.00);
    scriptInterface.SetAnimationParameterFeature(n"DOFControl", dofAnimFeature);
  }

  protected final func SetWeaponHolster(scriptInterface: ref<StateGameScriptInterface>, newState: Bool) -> Void {
    let weaponHolsterAnimFeature: ref<AnimFeature_PlayerCoverActionWeaponHolster> = new AnimFeature_PlayerCoverActionWeaponHolster();
    weaponHolsterAnimFeature.isWeaponHolstered = newState;
    scriptInterface.SetAnimationParameterFeature(n"PlayerCoverWeaponHolstered", weaponHolsterAnimFeature);
  }

  protected final func ProcessWeaponSlotInput(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustReleased(n"WeaponSlot1") {
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestWeaponSlot1);
    } else {
      if scriptInterface.IsActionJustReleased(n"WeaponSlot2") {
        this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestWeaponSlot2);
      } else {
        if scriptInterface.IsActionJustReleased(n"WeaponSlot3") {
          this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestWeaponSlot3);
        } else {
          if scriptInterface.IsActionJustReleased(n"WeaponSlot4") {
            this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestWeaponSlot4);
          };
        };
      };
    };
    return false;
  }

  protected final func CheckRangedAttackInput(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"RangedAttack") && !DefaultTransition.IsInteractingWithTerminal(scriptInterface);
  }

  protected final func CheckMeleeStatesForCombatGadget(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Bool {
    let inQuickmelee: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon) == EnumInt(gamePSMRangedWeaponStates.QuickMelee);
    if UpperBodyTransition.HasMeleeWeaponEquipped(scriptInterface) {
      return !stateContext.GetBoolParameter(n"isAttacking", true);
    };
    return !inQuickmelee;
  }
}

public abstract class UpperBodyEventsTransition extends UpperBodyTransition {

  public let m_switchButtonPushed: Bool;

  public let m_cyclePushed: Bool;

  public let m_delay: Float;

  public let m_cycleBlock: Float;

  public let m_switchPending: Bool;

  public let m_counter: Int32;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let switchItemButtonPushed: StateResultBool = stateContext.GetPermanentBoolParameter(n"switchItemButtonPushed");
    let switchItemPending: StateResultBool = stateContext.GetPermanentBoolParameter(n"switchItemPending");
    let switchItemDelay: StateResultFloat = stateContext.GetPermanentFloatParameter(n"switchItemDelay");
    let counter: StateResultInt = stateContext.GetPermanentIntParameter(n"switchCounter");
    let cycleBlock: StateResultFloat = stateContext.GetPermanentFloatParameter(n"switchCycleBlock");
    let cyclePushed: StateResultBool = stateContext.GetPermanentBoolParameter(n"cyclePushed");
    if switchItemButtonPushed.valid {
      this.m_switchButtonPushed = switchItemButtonPushed.value;
      this.m_switchPending = switchItemPending.value;
      this.m_delay = switchItemDelay.value;
      this.m_counter = counter.value;
      this.m_cycleBlock = cycleBlock.value;
      this.m_cyclePushed = cyclePushed.value;
    } else {
      this.ResetEquipVars(stateContext);
    };
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SyncEquipVarsToPermanentStorage(stateContext);
  }

  protected func ResetEquipVars(stateContext: ref<StateContext>) -> Void {
    this.m_switchButtonPushed = false;
    this.m_switchPending = false;
    this.m_cyclePushed = false;
    this.m_delay = 0.00;
    this.m_counter = 0;
    this.m_cycleBlock = 0.00;
    this.SyncEquipVarsToPermanentStorage(stateContext);
  }

  protected func SyncEquipVarsToPermanentStorage(stateContext: ref<StateContext>) -> Void {
    stateContext.SetPermanentBoolParameter(n"switchItemButtonPushed", this.m_switchButtonPushed, true);
    stateContext.SetPermanentBoolParameter(n"switchItemPending", this.m_switchPending, true);
    stateContext.SetPermanentFloatParameter(n"switchItemDelay", this.m_delay, true);
    stateContext.SetPermanentIntParameter(n"switchCounter", this.m_counter, true);
    stateContext.SetPermanentFloatParameter(n"switchCycleBlock", this.m_cycleBlock, true);
    stateContext.SetPermanentBoolParameter(n"cyclePushed", this.m_cyclePushed, true);
  }

  protected final func UpdateSwitchItem(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let holsterDelay: Float = 0.25;
    let nextWeaponJustPressed: Bool = scriptInterface.IsActionJustPressed(n"NextWeapon");
    let previousWeaponJustPressed: Bool = scriptInterface.IsActionJustPressed(n"PreviousWeapon");
    let switchItemJustTapped: Bool = scriptInterface.IsActionJustTapped(n"SwitchItem");
    if !this.m_switchButtonPushed && !this.m_cyclePushed && !nextWeaponJustPressed && !previousWeaponJustPressed && !switchItemJustTapped {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FirearmsNoSwitch") || StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"ShootingRangeCompetition") || StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Fists") || stateContext.IsStateMachineActive(n"Consumable") || stateContext.IsStateMachineActive(n"CombatGadget") || this.CheckEquipmentStateMachineState(stateContext, EEquipmentSide.Right, EEquipmentState.Equipping) {
      return false;
    };
    if this.m_cyclePushed {
      this.m_cycleBlock += timeDelta;
      if this.m_cycleBlock > 0.50 {
        this.m_cycleBlock = 0.00;
        this.m_cyclePushed = false;
        stateContext.SetPermanentBoolParameter(n"cyclePushed", this.m_cyclePushed, true);
      };
    };
    if nextWeaponJustPressed && !this.m_cyclePushed && !this.m_switchPending && DefaultTransition.HasRightWeaponEquipped(scriptInterface) && this.CheckEquipmentStateMachineState(stateContext, EEquipmentSide.Right, EEquipmentState.Equipped) {
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.CycleNextWeaponWheelItem);
      this.m_cyclePushed = true;
      stateContext.SetPermanentBoolParameter(n"cyclePushed", this.m_cyclePushed, true);
      return true;
    };
    if previousWeaponJustPressed && !this.m_cyclePushed && !this.m_switchPending && DefaultTransition.HasRightWeaponEquipped(scriptInterface) && this.CheckEquipmentStateMachineState(stateContext, EEquipmentSide.Right, EEquipmentState.Equipped) {
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.CyclePreviousWeaponWheelItem);
      this.m_cyclePushed = true;
      stateContext.SetPermanentBoolParameter(n"cyclePushed", this.m_cyclePushed, true);
      return true;
    };
    if switchItemJustTapped && !this.m_cyclePushed {
      this.m_switchButtonPushed = true;
      this.m_counter += 1;
    };
    if this.m_switchButtonPushed {
      this.m_delay += timeDelta;
      if this.m_delay < holsterDelay && this.m_switchButtonPushed && !this.m_switchPending {
        if EquipmentSystem.GetData(scriptInterface.executionOwner).CycleWeapon(true, true) != ItemID.undefined() {
          this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipWeapon);
          this.m_switchPending = true;
        };
        return false;
      };
      if this.m_delay >= holsterDelay {
        if this.m_counter == 1 {
          this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.CycleNextWeaponWheelItem);
        } else {
          if this.m_counter > 1 && EquipmentSystem.GetData(scriptInterface.executionOwner).CycleWeapon(true, true) == ItemID.undefined() && !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FirearmsNoUnequip") {
            this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipWeapon);
          };
        };
        this.ResetEquipVars(stateContext);
      };
      return true;
    };
    return false;
  }

  protected final func CheckSwitchInput(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !stateContext.GetBoolParameter(n"cyclePushed", true) && this.GetInStateTime() > 1.00 {
      return scriptInterface.IsActionJustPressed(n"NextWeapon") || scriptInterface.IsActionJustPressed(n"PreviousWeapon");
    };
    return false;
  }
}

public class ForceEmptyHandsDecisions extends UpperBodyTransition {

  public const let stateBodyDone: Bool;

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !scriptInterface.CanEquipItem(stateContext) {
      return false;
    };
    if this.IsEmptyHandsForced(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.stateBodyDone;
  }

  protected final const func ToEmptyHands(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.IsEmptyHandsForced(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToSingleWield(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.IsEmptyHandsForced(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }
}

public class ForceEmptyHandsEvents extends UpperBodyEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let upperBody: ref<PSMStopStateMachine> = new PSMStopStateMachine();
    this.ResetEquipVars(stateContext);
    this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipAll);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UpperBody, EnumInt(gamePSMUpperBodyStates.ForceEmptyHands));
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle) == EnumInt(gamePSMVehicle.Driving) {
      upperBody = new PSMStopStateMachine();
      upperBody.stateMachineIdentifier.definitionName = n"UpperBody";
      scriptInterface.executionOwner.QueueEvent(upperBody);
    };
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let dpadAction: ref<DPADActionPerformed>;
    let notificationEvent: ref<UIInGameNotificationEvent>;
    if scriptInterface.IsActionJustReleased(n"UseConsumable") {
      dpadAction = new DPADActionPerformed();
      dpadAction.action = EHotkey.DPAD_UP;
      if !stateContext.IsStateMachineActive(n"Consumable") && this.CheckActiveConsumable(scriptInterface) && !this.AreChoiceHubsActive(scriptInterface) && this.CheckConsumableLootDataCondition(scriptInterface) && !this.IsInFocusMode(scriptInterface) {
        if !this.IsUsingConsumableRestricted(scriptInterface) {
          dpadAction.successful = true;
          scriptInterface.GetUISystem().QueueEvent(dpadAction);
          this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestConsumable);
        } else {
          notificationEvent = new UIInGameNotificationEvent();
          notificationEvent.m_notificationType = UIInGameNotificationType.ActionRestriction;
          scriptInterface.GetUISystem().QueueEvent(notificationEvent);
        };
      } else {
        scriptInterface.GetUISystem().QueueEvent(dpadAction);
      };
    };
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UpperBody, EnumInt(gamePSMUpperBodyStates.Default));
  }
}

public class ForceSafeDecisions extends UpperBodyTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsSafeStateForced(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToEmptyHands(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.IsSafeStateForced(stateContext, scriptInterface) || DefaultTransition.HasRightWeaponEquipped(scriptInterface) && this.GetInStateTime() >= 0.45 && this.EmptyHandsCondition(stateContext, scriptInterface) {
      return true;
    };
    if !IsMultiplayer() && DefaultTransition.HasRightWeaponEquipped(scriptInterface) && this.GetStaticFloatParameterDefault("timeToAutoUnequipWeapon", -1.00) > 0.00 && stateContext.GetConditionFloat(n"ForceSafeCurrentTimeToAutoUnequip") >= this.GetStaticFloatParameterDefault("timeToAutoUnequipWeapon", -1.00) + stateContext.GetConditionFloat(n"ForceSafeTimeStampToAutoUnequip") {
      return true;
    };
    return false;
  }

  protected final const func ToSingleWield(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.IsSafeStateForced(stateContext, scriptInterface) && DefaultTransition.HasRightWeaponEquipped(scriptInterface) {
      return true;
    };
    return false;
  }
}

public class ForceSafeEvents extends UpperBodyEventsTransition {

  public let m_safeAnimFeature: ref<AnimFeature_SafeAction>;

  public let m_weaponObjectID: TweakDBID;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    stateContext.SetPermanentBoolParameter(n"WeaponInSafe", true, true);
    scriptInterface.SetAnimationParameterFloat(n"safe", 1.00);
    this.m_safeAnimFeature = new AnimFeature_SafeAction();
    this.m_weaponObjectID = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(DefaultTransition.GetActiveWeapon(scriptInterface).GetItemID())).GetID();
    stateContext.SetConditionFloatParameter(n"ForceSafeTimeStampToAutoUnequip", this.GetInStateTime(), true);
    stateContext.SetConditionFloatParameter(n"ForceSafeCurrentTimeToAutoUnequip", 0.00, true);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if DefaultTransition.HasRightWeaponEquipped(scriptInterface) {
      if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel) == EnumInt(gamePSMHighLevel.SceneTier2) {
        this.UpdateSwitchItem(timeDelta, stateContext, scriptInterface);
      };
      if scriptInterface.IsActionJustPressed(n"RangedAttack") && !WeaponObject.IsMagazineEmpty(DefaultTransition.GetActiveWeapon(scriptInterface)) {
        scriptInterface.PushAnimationEvent(n"SafeAction");
      } else {
        if scriptInterface.GetActionValue(n"RangedAttack") > 0.50 {
          stateContext.SetPermanentBoolParameter(n"TriggerHeld", true, true);
          this.m_safeAnimFeature.triggerHeld = true;
        } else {
          if scriptInterface.GetActionValue(n"RangedAttack") < 0.50 {
            stateContext.SetPermanentBoolParameter(n"TriggerHeld", false, true);
            this.m_safeAnimFeature.triggerHeld = false;
          } else {
            if scriptInterface.IsActionJustReleased(n"RangedAttack") {
              stateContext.SetConditionFloatParameter(n"ForceSafeTimeStampToAutoUnequip", stateContext.GetConditionFloat(n"ForceSafeTimeStampToAutoUnequip") + this.GetStaticFloatParameterDefault("addedTimeToAutoUnequipAfterSafeAction", 0.00), true);
            };
          };
        };
      };
      stateContext.SetConditionFloatParameter(n"ForceSafeCurrentTimeToAutoUnequip", stateContext.GetConditionFloat(n"ForceSafeCurrentTimeToAutoUnequip") + timeDelta, true);
      this.m_safeAnimFeature.safeActionDuration = TDB.GetFloat(this.m_weaponObjectID + t".safeActionDuration");
      scriptInterface.SetAnimationParameterFeature(n"SafeAction", this.m_safeAnimFeature);
      scriptInterface.SetAnimationParameterFeature(n"SafeAction", this.m_safeAnimFeature, DefaultTransition.GetActiveWeapon(scriptInterface));
    } else {
      if !DefaultTransition.HasRightWeaponEquipped(scriptInterface) {
        if scriptInterface.IsActionJustReleased(n"SwitchItem") || this.CheckRangedAttackInput(scriptInterface) {
          if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"OneHandedFirearms") {
            this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableOneHandedRangedWeapon);
          } else {
            if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Melee") {
              this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableMeleeWeapon);
            } else {
              if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Fists") {
                this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestFists);
              } else {
                if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Firearms") {
                  this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableRangedWeapon);
                } else {
                  this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableWeapon);
                };
              };
            };
          };
        };
      };
    };
  }
}

public class EmptyHandsDecisions extends UpperBodyTransition {

  public const let stateBodyDone: Bool;

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !scriptInterface.CanEquipItem(stateContext) {
      return false;
    };
    if !DefaultTransition.HasRightWeaponEquipped(scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.stateBodyDone;
  }

  protected final const func ToSingleWield(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return DefaultTransition.HasRightWeaponEquipped(scriptInterface);
  }
}

public class EmptyHandsEvents extends UpperBodyEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    scriptInterface.ActivateCameraSetting(n"weapon");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UpperBody, EnumInt(gamePSMUpperBodyStates.Default));
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Default));
    this.SetWeaponHolster(scriptInterface, true);
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let dpadAction: ref<DPADActionPerformed>;
    if this.IsInTakedownState(stateContext) || this.GetSceneTier(scriptInterface) > 2 {
      return;
    };
    if !this.CheckGenericEquipItemConditions(stateContext, scriptInterface) || StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FirearmsNoUnequipNoSwitch") || StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"ShootingRangeCompetition") {
      return;
    };
    this.ProcessCombatGadgetActionInputCaching(scriptInterface, stateContext);
    if (scriptInterface.IsActionJustReleased(n"SwitchItem") || this.CheckRangedAttackInput(scriptInterface) || this.CheckSwitchInput(stateContext, scriptInterface)) && !stateContext.IsStateMachineActive(n"CombatGadget") && !stateContext.IsStateMachineActive(n"Consumable") && !stateContext.IsStateMachineActive(n"LeftHandCyberware") && (!this.IsCarryingBody(scriptInterface) || this.IsCarryingBody(scriptInterface) && !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoCombat")) {
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"OneHandedFirearms") {
        this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableOneHandedRangedWeapon);
      } else {
        if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Melee") {
          this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableMeleeWeapon);
        } else {
          if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Fists") {
            this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestFists);
          } else {
            if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Firearms") {
              this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableRangedWeapon);
            } else {
              this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableWeapon);
            };
          };
        };
      };
    } else {
      if !stateContext.IsStateMachineActive(n"CombatGadget") && !this.IsCarryingBody(scriptInterface) && this.ProcessWeaponSlotInput(scriptInterface) {
        return;
      };
      if scriptInterface.IsActionJustReleased(n"UseConsumable") {
        dpadAction = new DPADActionPerformed();
        dpadAction.action = EHotkey.DPAD_UP;
        if !stateContext.IsStateMachineActive(n"Consumable") && !stateContext.IsStateMachineActive(n"CombatGadget") && !stateContext.IsStateMachineActive(n"LeftHandCyberware") && this.CheckActiveConsumable(scriptInterface) && !this.IsInUpperBodyState(stateContext, n"temporaryUnequip") && !this.IsInUpperBodyState(stateContext, n"forceEmptyHands") && !this.AreChoiceHubsActive(scriptInterface) && this.CheckConsumableLootDataCondition(scriptInterface) && !this.IsInFocusMode(scriptInterface) && !this.IsCarryingBody(scriptInterface) && !this.IsUsingConsumableRestricted(scriptInterface) {
          dpadAction.successful = true;
          scriptInterface.GetUISystem().QueueEvent(dpadAction);
          this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestConsumable);
        } else {
          scriptInterface.GetUISystem().QueueEvent(dpadAction);
        };
      } else {
        if scriptInterface.IsActionJustPressed(n"UseCombatGadget") || stateContext.GetBoolParameter(n"cgCached", true) {
          dpadAction = new DPADActionPerformed();
          dpadAction.action = EHotkey.RB;
          if this.IsUsingLeftHandAllowed(scriptInterface) && !stateContext.IsStateMachineActive(n"Consumable") && !stateContext.IsStateMachineActive(n"CombatGadget") && !this.IsInUpperBodyState(stateContext, n"forceEmptyHands") && !this.AreChoiceHubsActive(scriptInterface) && !this.IsInSafeZone(scriptInterface) && this.GetInStateTime() > 0.30 && !this.IsCarryingBody(scriptInterface) && !DefaultTransition.IsInWorkspot(scriptInterface) {
            dpadAction.successful = true;
            scriptInterface.GetUISystem().QueueEvent(dpadAction);
            if this.CheckItemCategoryInQuickWheel(scriptInterface, gamedataItemCategory.Gadget) {
              this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestGadget);
            } else {
              if this.CheckItemCategoryInQuickWheel(scriptInterface, gamedataItemCategory.Cyberware) {
                this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestGadget);
                stateContext.RemovePermanentBoolParameter(n"cgCached");
              };
            };
          } else {
            scriptInterface.GetUISystem().QueueEvent(dpadAction);
          };
        } else {
          this.UpdateSwitchItem(timeDelta, stateContext, scriptInterface);
        };
      };
    };
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class SingleWieldDecisions extends UpperBodyTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if DefaultTransition.HasRightWeaponEquipped(scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToEmptyHands(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent>;
    if !DefaultTransition.HasRightWeaponEquipped(scriptInterface) || this.GetInStateTime() >= 0.45 && this.EmptyHandsCondition(stateContext, scriptInterface) {
      broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.WeaponHolstered);
      };
      return true;
    };
    if DefaultTransition.HasRightWeaponEquipped(scriptInterface) && stateContext.GetBoolParameter(n"requestWeaponUnequip", false) {
      broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.WeaponHolstered);
      };
      return true;
    };
    return false;
  }
}

public class SingleWieldEvents extends UpperBodyEventsTransition {

  public let m_hasInstantEquipHackBeenApplied: Bool;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.m_hasInstantEquipHackBeenApplied = false;
    if scriptInterface.executionOwner.IsControlledByAnotherClient() {
      this.InstantEquipHACK(stateContext, scriptInterface);
    };
    this.SetWeaponHolster(scriptInterface, false);
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let dpadAction: ref<DPADActionPerformed>;
    let isCPOControlScheme: Bool;
    let isPerformingMeleeAttack: Bool;
    let rhIden: StateMachineIdentifier;
    if scriptInterface.executionOwner.IsControlledByAnotherClient() && !this.m_hasInstantEquipHackBeenApplied {
      this.InstantEquipHACK(stateContext, scriptInterface);
    };
    if this.IsInTakedownState(stateContext) || this.GetSceneTier(scriptInterface) > 2 {
      return;
    };
    if stateContext.GetConditionBool(n"AimingInterrupted") && (scriptInterface.GetActionValue(n"CameraAim") < 0.50 || this.GetInStateTime() > 1.00) {
      stateContext.SetConditionBoolParameter(n"AimingInterrupted", false, true);
    };
    rhIden.definitionName = n"Equipment";
    rhIden.referenceName = n"RightHand";
    if !stateContext.GetBoolParameter(n"isAttacking", true) && stateContext.IsStateActiveWithIdentifier(rhIden, n"unequipCycle") {
      MeleeTransition.UpdateMeleeInputBuffer(stateContext, scriptInterface, true);
    };
    if !this.CheckGenericEquipItemConditions(stateContext, scriptInterface) {
      return;
    };
    if scriptInterface.IsActionJustReleased(n"UseConsumable") {
      dpadAction = new DPADActionPerformed();
      dpadAction.action = EHotkey.DPAD_UP;
      if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Melee) == EnumInt(gamePSMMelee.Attack) {
        isPerformingMeleeAttack = true;
      };
      if !stateContext.IsStateMachineActive(n"Consumable") && !stateContext.IsStateMachineActive(n"CombatGadget") && !stateContext.IsStateMachineActive(n"LeftHandCyberware") && this.CheckActiveConsumable(scriptInterface) && this.CheckEquipmentStateMachineState(stateContext, EEquipmentSide.Right, EEquipmentState.Equipped) && !this.IsInUpperBodyState(stateContext, n"temporaryUnequip") && !this.IsInUpperBodyState(stateContext, n"forceEmptyHands") && !this.AreChoiceHubsActive(scriptInterface) && this.CheckConsumableLootDataCondition(scriptInterface) && !this.IsInFocusMode(scriptInterface) && !this.IsUsingConsumableRestricted(scriptInterface) && !isPerformingMeleeAttack {
        dpadAction.successful = true;
        scriptInterface.GetUISystem().QueueEvent(dpadAction);
        this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestConsumable);
        return;
      };
      scriptInterface.GetUISystem().QueueEvent(dpadAction);
    };
    this.ProcessCombatGadgetActionInputCaching(scriptInterface, stateContext);
    if scriptInterface.IsActionJustPressed(n"UseCombatGadget") || stateContext.GetBoolParameter(n"cgCached", true) {
      dpadAction = new DPADActionPerformed();
      dpadAction.action = EHotkey.RB;
      if this.IsUsingLeftHandAllowed(scriptInterface) && !stateContext.IsStateMachineActive(n"Consumable") && !this.IsInUpperBodyState(stateContext, n"temporaryUnequip") && !this.IsInUpperBodyState(stateContext, n"forceEmptyHands") && this.CheckEquipmentStateMachineState(stateContext, EEquipmentSide.Right, EEquipmentState.Equipped) && this.CheckMeleeStatesForCombatGadget(scriptInterface, stateContext) && !this.AreChoiceHubsActive(scriptInterface) && !stateContext.IsStateMachineActive(n"CombatGadget") && this.GetInStateTime() > 0.30 && !this.IsInSafeZone(scriptInterface) && !DefaultTransition.IsInWorkspot(scriptInterface) {
        dpadAction.successful = true;
        scriptInterface.GetUISystem().QueueEvent(dpadAction);
        if this.CheckItemCategoryInQuickWheel(scriptInterface, gamedataItemCategory.Gadget) {
          this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestGadget);
          return;
        };
        if this.CheckItemCategoryInQuickWheel(scriptInterface, gamedataItemCategory.Cyberware) {
          this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestGadget);
          stateContext.RemovePermanentBoolParameter(n"cgCached");
          return;
        };
      } else {
        scriptInterface.GetUISystem().QueueEvent(dpadAction);
      };
    };
    isCPOControlScheme = GameInstance.GetRuntimeInfo(scriptInterface.executionOwner.GetGame()).IsMultiplayer() || scriptInterface.GetPlayerSystem().IsCPOControlSchemeForced();
    if isCPOControlScheme && (scriptInterface.IsActionJustReleased(n"SwitchItem") || scriptInterface.GetActionValue(n"SwitchItemMW") != 0.00) {
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.CycleWeaponWheelItem);
    } else {
      if !isCPOControlScheme && this.UpdateSwitchItem(timeDelta, stateContext, scriptInterface) {
        return;
      };
      if !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FirearmsNoUnequipNoSwitch") && !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FirearmsNoSwitch") && !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"ShootingRangeCompetition") && this.ProcessWeaponSlotInput(scriptInterface) {
        return;
      };
    };
  }

  public final func InstantEquipHACK(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let rightHandItemHandling: ref<AnimFeature_EquipUnequipItem>;
    let weaponID: ItemID;
    let weaponRecData: ref<WeaponItem_Record>;
    let weapon: ref<WeaponObject> = DefaultTransition.GetActiveWeapon(scriptInterface);
    if IsDefined(weapon) {
      weaponID = weapon.GetItemID();
      weaponRecData = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weaponID));
      rightHandItemHandling = new AnimFeature_EquipUnequipItem();
      rightHandItemHandling.itemState = 2;
      rightHandItemHandling.stateTransitionDuration = 0.00;
      rightHandItemHandling.itemType = weaponRecData.ItemType().AnimFeatureIndex();
      scriptInterface.SetAnimationParameterFeature(n"rightHandItemHandling", rightHandItemHandling);
      this.m_hasInstantEquipHackBeenApplied = true;
    };
  }
}

public class AimingStateDecisions extends UpperBodyTransition {

  private let m_callbackIDs: array<ref<CallbackHandle>>;

  private let m_executionOwner: wref<GameObject>;

  private let m_statListener: ref<DefaultTransitionStatListener>;

  private let m_statusEffectListener: ref<DefaultTransitionStatusEffectListener>;

  private let m_attachmentSlotListener: ref<AttachmentSlotsScriptListener>;

  private let m_sceneTier: Int32;

  private let m_vehicleState: Int32;

  private let m_highLevelState: Int32;

  private let m_combatGadgetState: Int32;

  private let m_takedownState: Int32;

  private let m_weaponState: Int32;

  private let m_cameraAimPressed: Bool;

  private let m_sceneAimForced: Bool;

  private let m_shouldAim: Bool;

  private let m_hasRightHandItemEquipped: Bool;

  private let m_isDead: Bool;

  private let m_isWeaponBlockingAiming: Bool;

  private let m_visionModeActive: Bool;

  private let m_isDodging: Bool;

  private let m_hasThrowableMeleeWeapon: Bool;

  private let m_canAimWhileDodging: Bool;

  private let m_canThrowWeapon: Bool;

  private let m_aimForced: Bool;

  private let m_beingCreated: Bool;

  @default(AimingStateDecisions, 100000.f)
  private let m_mouseZoomLevel: Float;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    let attachmentSlotCallback: ref<DefaultTransitionAttachmentSlotsCallback>;
    this.m_beingCreated = true;
    this.m_executionOwner = scriptInterface.executionOwner;
    scriptInterface.executionOwner.RegisterInputListener(this, n"CameraAim");
    this.m_cameraAimPressed = scriptInterface.GetActionValue(n"CameraAim") > 0.00;
    this.m_statusEffectListener = new DefaultTransitionStatusEffectListener();
    this.m_statusEffectListener.m_transitionOwner = this;
    scriptInterface.GetStatusEffectSystem().RegisterListener(scriptInterface.owner.GetEntityID(), this.m_statusEffectListener);
    this.m_aimForced = StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"ForceAim");
    allBlackboardDef = GetAllBlackboardDefs();
    ArrayPush(this.m_callbackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.SceneTier, this, n"OnSceneTierChanged", true));
    ArrayPush(this.m_callbackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vehicle, this, n"OnVehicleChanged", true));
    ArrayPush(this.m_callbackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.HighLevel, this, n"OnHighLevelChanged", true));
    ArrayPush(this.m_callbackIDs, scriptInterface.localBlackboard.RegisterListenerBool(allBlackboardDef.PlayerStateMachine.SceneAimForced, this, n"OnSceneAimForcedChanged", true));
    ArrayPush(this.m_callbackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vitals, this, n"OnVitalsChanged", true));
    ArrayPush(this.m_callbackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Takedown, this, n"OnTakedownChanged", true));
    ArrayPush(this.m_callbackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.CombatGadget, this, n"OnCombatGadgetChanged", true));
    ArrayPush(this.m_callbackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vision, this, n"OnVisionChanged", true));
    ArrayPush(this.m_callbackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Weapon, this, n"OnWeaponStateChanged", true));
    ArrayPush(this.m_callbackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Locomotion, this, n"OnLocomoatoinStateChanged", true));
    attachmentSlotCallback = new DefaultTransitionAttachmentSlotsCallback();
    attachmentSlotCallback.m_transitionOwner = this;
    attachmentSlotCallback.slotID = t"AttachmentSlots.WeaponRight";
    this.m_attachmentSlotListener = scriptInterface.GetTransactionSystem().RegisterAttachmentSlotListener(this.m_executionOwner, attachmentSlotCallback);
    this.m_statListener = new DefaultTransitionStatListener();
    this.m_statListener.m_transitionOwner = this;
    scriptInterface.GetStatsSystem().RegisterListener(Cast(this.m_executionOwner.GetEntityID()), this.m_statListener);
    this.m_canThrowWeapon = scriptInterface.HasStatFlag(gamedataStatType.CanThrowWeapon);
    this.m_canAimWhileDodging = scriptInterface.HasStatFlag(gamedataStatType.CanAimWhileDodging);
    this.m_beingCreated = false;
    this.UpdateEnterConditionEnabled();
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
    this.m_statusEffectListener = null;
    ArrayClear(this.m_callbackIDs);
    scriptInterface.GetTransactionSystem().UnregisterAttachmentSlotListener(this.m_executionOwner, this.m_attachmentSlotListener);
    scriptInterface.GetStatsSystem().UnregisterListener(Cast(this.m_executionOwner.GetEntityID()), this.m_statListener);
  }

  private final func GetShouldAimValue() -> Bool {
    if this.m_aimForced {
      return true;
    };
    if this.m_sceneTier > 3 {
      return false;
    };
    if this.m_sceneTier < 3 && this.m_vehicleState != EnumInt(gamePSMVehicle.Default) && this.m_vehicleState != EnumInt(gamePSMVehicle.Combat) {
      return false;
    };
    if this.m_cameraAimPressed {
      return true;
    };
    if this.m_highLevelState > EnumInt(gamePSMHighLevel.SceneTier1) && this.m_highLevelState <= EnumInt(gamePSMHighLevel.SceneTier5) && this.m_sceneAimForced {
      return true;
    };
    return false;
  }

  private final func ShouldCheckEnterCondition() -> Bool {
    if this.m_isDead {
      return false;
    };
    if this.m_highLevelState != EnumInt(gamePSMHighLevel.SceneTier1) && this.m_highLevelState != EnumInt(gamePSMHighLevel.SceneTier2) && this.m_highLevelState != EnumInt(gamePSMHighLevel.SceneTier3) {
      return false;
    };
    if this.m_takedownState == EnumInt(gamePSMTakedown.Grapple) || this.m_takedownState == EnumInt(gamePSMTakedown.Leap) || this.m_takedownState == EnumInt(gamePSMTakedown.Takedown) {
      return false;
    };
    if this.m_combatGadgetState > EnumInt(gamePSMCombatGadget.Default) && this.m_combatGadgetState < EnumInt(gamePSMCombatGadget.WaitForUnequip) && !this.m_visionModeActive {
      return false;
    };
    if this.m_isWeaponBlockingAiming {
      return false;
    };
    if this.m_hasThrowableMeleeWeapon && !this.m_canThrowWeapon {
      return false;
    };
    if !this.m_canAimWhileDodging && this.m_isDodging {
      return false;
    };
    return true;
  }

  private final func UpdateEnterConditionEnabled() -> Void {
    if this.m_beingCreated {
      return;
    };
    this.m_shouldAim = this.GetShouldAimValue();
    this.EnableOnEnterCondition(this.m_shouldAim && this.ShouldCheckEnterCondition());
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    this.m_cameraAimPressed = ListenerAction.GetValue(action) > 0.00;
    this.UpdateEnterConditionEnabled();
  }

  protected cb func OnSceneTierChanged(value: Int32) -> Bool {
    this.m_sceneTier = value;
    this.UpdateEnterConditionEnabled();
  }

  protected cb func OnVehicleChanged(value: Int32) -> Bool {
    this.m_vehicleState = value;
    this.UpdateEnterConditionEnabled();
  }

  protected cb func OnHighLevelChanged(value: Int32) -> Bool {
    this.m_highLevelState = value;
    this.UpdateEnterConditionEnabled();
  }

  protected cb func OnSceneAimForcedChanged(value: Bool) -> Bool {
    this.m_sceneAimForced = value;
    this.UpdateEnterConditionEnabled();
  }

  protected cb func OnVitalsChanged(value: Int32) -> Bool {
    this.m_isDead = value == EnumInt(gamePSMVitals.Dead);
    this.UpdateEnterConditionEnabled();
  }

  protected cb func OnTakedownChanged(value: Int32) -> Bool {
    this.m_takedownState = value;
    this.UpdateEnterConditionEnabled();
  }

  protected cb func OnCombatGadgetChanged(value: Int32) -> Bool {
    this.m_combatGadgetState = value;
    this.UpdateEnterConditionEnabled();
  }

  protected cb func OnVisionChanged(value: Int32) -> Bool {
    this.m_visionModeActive = value == EnumInt(gamePSMVision.Focus);
    this.UpdateEnterConditionEnabled();
  }

  protected cb func OnWeaponStateChanged(value: Int32) -> Bool {
    this.m_weaponState = value;
    this.m_isWeaponBlockingAiming = value == EnumInt(gamePSMRangedWeaponStates.QuickMelee) || value == EnumInt(gamePSMRangedWeaponStates.Overheat) || value == EnumInt(gamePSMRangedWeaponStates.Reload);
    this.UpdateEnterConditionEnabled();
  }

  protected cb func OnLocomoatoinStateChanged(value: Int32) -> Bool {
    this.m_isDodging = value == EnumInt(gamePSMLocomotionStates.Dodge) || value == EnumInt(gamePSMLocomotionStates.DodgeAir);
    this.UpdateEnterConditionEnabled();
  }

  public func OnStatusEffectApplied(statusEffect: wref<StatusEffect_Record>) -> Void {
    if !this.m_aimForced {
      if statusEffect.GameplayTagsContains(n"ForceAim") {
        this.m_aimForced = true;
        this.UpdateEnterConditionEnabled();
      };
    };
  }

  public func OnStatusEffectRemoved(statusEffect: wref<StatusEffect_Record>) -> Void {
    if this.m_aimForced {
      if statusEffect.GameplayTagsContains(n"ForceAim") {
        this.m_aimForced = StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_executionOwner, n"ForceAim");
        if !this.m_aimForced {
          this.UpdateEnterConditionEnabled();
        };
      };
    };
  }

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, value: Float) -> Void {
    if Equals(statType, gamedataStatType.CanThrowWeapon) {
      this.m_canThrowWeapon = value > 0.00;
      this.UpdateEnterConditionEnabled();
    };
    if Equals(statType, gamedataStatType.CanAimWhileDodging) {
      this.m_canAimWhileDodging = value > 0.00;
      this.UpdateEnterConditionEnabled();
    };
  }

  public func OnItemEquipped(slot: TweakDBID, item: ItemID) -> Void {
    let tarnsactioSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_executionOwner.GetGame());
    this.m_hasRightHandItemEquipped = true;
    this.m_hasThrowableMeleeWeapon = tarnsactioSystem.HasTag(this.m_executionOwner, WeaponObject.GetMeleeWeaponTag(), item) && tarnsactioSystem.HasTag(this.m_executionOwner, n"Throwable", item);
    this.UpdateEnterConditionEnabled();
  }

  public func OnItemUnequipped(slot: TweakDBID, item: ItemID) -> Void {
    this.m_hasRightHandItemEquipped = false;
    this.m_hasThrowableMeleeWeapon = false;
    this.UpdateEnterConditionEnabled();
  }

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let pendingAdjust: Bool;
    if this.IsRightHandInUnequippingState(stateContext) || this.IsLeftHandInUnequippingState(stateContext) {
      return false;
    };
    if this.IsPlayerInBraindance(scriptInterface) {
      return false;
    };
    if stateContext.GetConditionBool(n"AimingInterrupted") || this.IsAimingSoftBlocked(stateContext, scriptInterface) {
      return false;
    };
    if this.IsAimingBlockedForTime(stateContext, scriptInterface) {
      return false;
    };
    if stateContext.IsStateMachineActive(n"Consumable") {
      return false;
    };
    if this.IsInItemWheelState(stateContext) {
      return false;
    };
    pendingAdjust = IsDefined(stateContext.GetTemporaryScriptableParameter(n"adjustTransform"));
    return !pendingAdjust;
  }

  protected final const func ToSingleWield(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.m_weaponState == EnumInt(gamePSMRangedWeaponStates.QuickMelee) {
      return true;
    };
    if !this.m_shouldAim {
      return true;
    };
    if this.IsAimingBlockedForTime(stateContext, scriptInterface) {
      return true;
    };
    if this.IsAimingHeldForTime(stateContext, scriptInterface) {
      return false;
    };
    if this.m_isWeaponBlockingAiming {
      return true;
    };
    if !this.m_hasRightHandItemEquipped || !this.IsRightHandInEquippedState(stateContext) {
      return false;
    };
    if stateContext.GetBoolParameter(n"InterruptAiming", false) {
      stateContext.SetConditionBoolParameter(n"AimingInterrupted", true, true);
      return true;
    };
    if stateContext.IsStateMachineActive(n"Consumable") {
      return true;
    };
    return false;
  }

  protected final const func ToEmptyHands(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.m_shouldAim && !this.m_hasRightHandItemEquipped;
  }

  protected final const func ToForceEmptyHands(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let emptyHandsForced: Bool = this.IsEmptyHandsForced(stateContext, scriptInterface);
    if this.m_hasRightHandItemEquipped && emptyHandsForced {
      return true;
    };
    return !this.m_shouldAim && emptyHandsForced;
  }

  protected final const func ToForceSafe(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.m_shouldAim && this.IsSafeStateForced(stateContext, scriptInterface);
  }
}

public class AimingStateEvents extends UpperBodyEventsTransition {

  private let m_aim: ref<AnimFeature_AimPlayer>;

  private let m_posAnimFeature: ref<AnimFeature_ProceduralIronsightData>;

  private let m_statusEffectListener: ref<DefaultTransitionStatusEffectListener>;

  private let m_weapon: wref<WeaponObject>;

  private let m_executionOwner: wref<GameObject>;

  @default(AimingStateEvents, 100000.f)
  private let m_mouseZoomLevel: Float;

  private let m_zoomLevelNum: Int32;

  private let m_numZoomLevels: Int32;

  private let m_delayAimSnap: Int32;

  private let m_isAiming: Bool;

  @default(AimingStateEvents, 0.0f)
  private let m_aimInTimeRemaining: Float;

  private let m_aimBroadcast: Bool;

  private let m_zoomLevel: Float;

  private let m_finalZoomLevel: Float;

  private let m_previousZoomLevel: Float;

  private let m_currentZoomLevel: Float;

  private let timeToBlendZoom: Float;

  private let time: Float;

  private let m_speed: Float;

  private let m_itemChanged: Bool;

  private let m_firearmsNoUnequipNoSwitch: Bool;

  private let m_shootingRangeCompetition: Bool;

  private let m_attachmentSlotListener: ref<AttachmentSlotsScriptListener>;

  protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_posAnimFeature = new AnimFeature_ProceduralIronsightData();
    this.m_aim = new AnimFeature_AimPlayer();
    this.m_executionOwner = scriptInterface.executionOwner;
    let attachmentSlotCallback: ref<DefaultTransitionAttachmentSlotsCallback> = new DefaultTransitionAttachmentSlotsCallback();
    attachmentSlotCallback.m_transitionOwner = this;
    attachmentSlotCallback.slotID = t"AttachmentSlots.WeaponRight";
    this.m_attachmentSlotListener = scriptInterface.GetTransactionSystem().RegisterAttachmentSlotListener(scriptInterface.executionOwner, attachmentSlotCallback);
    this.m_statusEffectListener = new DefaultTransitionStatusEffectListener();
    this.m_statusEffectListener.m_transitionOwner = this;
    scriptInterface.GetStatusEffectSystem().RegisterListener(scriptInterface.owner.GetEntityID(), this.m_statusEffectListener);
    this.m_firearmsNoUnequipNoSwitch = StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FirearmsNoUnequipNoSwitch");
    this.m_shootingRangeCompetition = StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"ShootingRangeCompetition");
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.GetTransactionSystem().UnregisterAttachmentSlotListener(scriptInterface.executionOwner, this.m_attachmentSlotListener);
    this.m_statusEffectListener = null;
  }

  public func OnItemEquipped(slot: TweakDBID, item: ItemID) -> Void {
    this.m_itemChanged = true;
  }

  public func OnItemUnequipped(slot: TweakDBID, item: ItemID) -> Void {
    this.m_itemChanged = true;
  }

  public func OnStatusEffectApplied(statusEffect: wref<StatusEffect_Record>) -> Void {
    if !this.m_firearmsNoUnequipNoSwitch {
      if statusEffect.GameplayTagsContains(n"FirearmsNoUnequipNoSwitch") {
        this.m_firearmsNoUnequipNoSwitch = true;
      };
    };
    if !this.m_shootingRangeCompetition {
      if statusEffect.GameplayTagsContains(n"ShootingRangeCompetition") {
        this.m_shootingRangeCompetition = true;
      };
    };
  }

  public func OnStatusEffectRemoved(statusEffect: wref<StatusEffect_Record>) -> Void {
    if this.m_firearmsNoUnequipNoSwitch {
      if statusEffect.GameplayTagsContains(n"FirearmsNoUnequipNoSwitch") {
        this.m_firearmsNoUnequipNoSwitch = StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_executionOwner, n"FirearmsNoUnequipNoSwitch");
      };
    };
    if this.m_shootingRangeCompetition {
      if statusEffect.GameplayTagsContains(n"ShootingRangeCompetition") {
        this.m_shootingRangeCompetition = StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_executionOwner, n"ShootingRangeCompetition");
      };
    };
  }

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    if this.m_itemChanged {
      this.m_weapon = this.GetWeaponObject(scriptInterface);
    };
    stateContext.SetConditionBoolParameter(n"AimingInterrupted", false, true);
    scriptInterface.SetAnimationParameterBool(n"has_scope", this.m_weapon.HasScope());
    stateContext.SetTemporaryBoolParameter(n"InterruptSprint", true, true);
    stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UpperBody, EnumInt(gamePSMUpperBodyStates.Aim));
    this.PlayEffectOnHeldItems(scriptInterface, n"lightswitch");
    this.OnAimStartBegin(stateContext, scriptInterface);
    this.m_numZoomLevels = this.GetStaticIntParameterDefault("maxNumberOfZoomLevels", 1);
    if this.m_itemChanged {
      this.UpdateWeaponOffsetPosition(scriptInterface);
    };
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    this.m_itemChanged = false;
  }

  protected final func OnAimStartBegin(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let usingCover: Bool;
    scriptInterface.GetTargetingSystem().OnAimStartBegin(scriptInterface.owner);
    if IsDefined(this.m_weapon) {
      this.m_aimInTimeRemaining = scriptInterface.GetStatsSystem().GetStatValue(Cast(this.m_weapon.GetEntityID()), gamedataStatType.AimInTime);
    } else {
      this.m_aimInTimeRemaining = 0.00;
      scriptInterface.GetTargetingSystem().OnAimStartEnd(scriptInterface.owner);
    };
    usingCover = NotEquals(scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCoverDirection(scriptInterface.executionOwner), IntEnum(0l));
    if usingCover {
      this.m_delayAimSnap = 2;
    } else {
      this.m_delayAimSnap = 0;
      this.EvaluateAimSnap(stateContext, scriptInterface);
    };
    this.NotifyWeaponObject(scriptInterface, true);
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let dpadAction: ref<DPADActionPerformed>;
    let weapon: ref<WeaponObject>;
    if stateContext.GetBoolParameter(n"ReevaluateAiming", false) {
      scriptInterface.GetTargetingSystem().OnAimStop(scriptInterface.owner);
      this.OnAimStartBegin(stateContext, scriptInterface);
      return;
    };
    if this.m_aimInTimeRemaining > 0.00 {
      this.m_aimInTimeRemaining -= timeDelta;
      if this.m_aimInTimeRemaining <= 0.00 {
        scriptInterface.GetTargetingSystem().OnAimStartEnd(scriptInterface.owner);
      };
    };
    if this.m_delayAimSnap > 0 {
      this.m_delayAimSnap -= 1;
      if this.m_delayAimSnap == 0 {
        this.EvaluateAimSnap(stateContext, scriptInterface);
      };
    };
    this.UpdateAimAnimFeature(stateContext, scriptInterface);
    this.UpdateAimDownSightsSfx(stateContext, scriptInterface);
    this.UpdateZoomVfx(scriptInterface);
    if this.m_firearmsNoUnequipNoSwitch || this.m_shootingRangeCompetition || this.IsInTakedownState(stateContext) || this.GetSceneTier(scriptInterface) > 2 || this.IsSafeStateForced(stateContext, scriptInterface) || !this.CheckGenericEquipItemConditions(stateContext, scriptInterface) || this.IsEmptyHandsForced(stateContext, scriptInterface) {
      return;
    };
    if !IsDefined(this.m_weapon) && (scriptInterface.IsActionJustReleased(n"SwitchItem") || scriptInterface.IsActionJustPressed(n"RangedAttack")) {
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"OneHandedFirearms") {
        this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableOneHandedRangedWeapon);
        return;
      };
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Melee") {
        this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableMeleeWeapon);
        return;
      };
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Fists") {
        this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestFists);
        return;
      };
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Firearms") {
        this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableRangedWeapon);
        return;
      };
      this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestLastUsedOrFirstAvailableWeapon);
      return;
    };
    if IsDefined(this.m_weapon) && this.UpdateSwitchItem(timeDelta, stateContext, scriptInterface) {
      return;
    };
    this.ProcessCombatGadgetActionInputCaching(scriptInterface, stateContext);
    if scriptInterface.IsActionJustPressed(n"UseCombatGadget") || stateContext.GetBoolParameter(n"cgCached", true) {
      dpadAction = new DPADActionPerformed();
      dpadAction.action = EHotkey.RB;
      if this.IsUsingLeftHandAllowed(scriptInterface) && !stateContext.IsStateMachineActive(n"Consumable") && !this.IsInUpperBodyState(stateContext, n"temporaryUnequip") && !this.IsInUpperBodyState(stateContext, n"forceEmptyHands") && this.CheckMeleeStatesForCombatGadget(scriptInterface, stateContext) && (this.CheckEquipmentStateMachineState(stateContext, EEquipmentSide.Right, EEquipmentState.Equipped) || this.CompareSMState(n"CoverAction", n"activateCover", stateContext)) && !this.AreChoiceHubsActive(scriptInterface) && !this.IsInSafeZone(scriptInterface) && !DefaultTransition.IsInWorkspot(scriptInterface) {
        dpadAction.successful = true;
        scriptInterface.GetUISystem().QueueEvent(dpadAction);
        if this.CheckItemCategoryInQuickWheel(scriptInterface, gamedataItemCategory.Gadget) {
          this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestGadget);
          return;
        };
        if this.CheckItemCategoryInQuickWheel(scriptInterface, gamedataItemCategory.Cyberware) {
          this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestGadget);
          stateContext.RemovePermanentBoolParameter(n"cgCached");
          return;
        };
      } else {
        scriptInterface.GetUISystem().QueueEvent(dpadAction);
      };
    };
    if this.m_aimInTimeRemaining < 0.00 && !this.m_aimBroadcast && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon) != EnumInt(gamePSMRangedWeaponStates.Safe) {
      weapon = this.GetWeaponObject(scriptInterface);
      if !WeaponObject.IsFists(weapon.GetItemID()) && weapon.IsRanged() {
        this.m_aimBroadcast = true;
        broadcaster = scriptInterface.owner.GetStimBroadcasterComponent();
        if IsDefined(broadcaster) {
          broadcaster.AddActiveStimuli(scriptInterface.owner, gamedataStimType.CrowdIllegalAction, -1.00);
        };
      };
    };
  }

  public final func PlayEffectOnHeldItems(scriptInterface: ref<StateGameScriptInterface>, effectName: CName) -> Void {
    let leftItem: ref<ItemObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponLeft");
    let spawnEffectEvent: ref<entSpawnEffectEvent> = new entSpawnEffectEvent();
    spawnEffectEvent.effectName = effectName;
    if IsDefined(leftItem) {
      leftItem.QueueEventToChildItems(spawnEffectEvent);
    };
    if IsDefined(this.m_weapon) {
      this.m_weapon.QueueEventToChildItems(spawnEffectEvent);
    };
  }

  protected final func GetWeaponObject(scriptInterface: ref<StateGameScriptInterface>) -> ref<WeaponObject> {
    return scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
  }

  protected final func EvaluateAimSnap(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let aimSnapSetting: ref<ConfigVarBool>;
    let perfectAimSnapParams: AimRequest;
    let settingGroup: ref<ConfigGroup>;
    let userSettings: ref<UserSettings>;
    let aimSnapEnabledInSetting: Bool = true;
    let weaponRecData: ref<WeaponItem_Record> = this.m_weapon.GetWeaponRecord();
    let isInvalidMeleeWeapon: Bool = this.m_weapon.IsMelee() && NotEquals(weaponRecData.ItemType().Type(), gamedataItemType.Wea_Knife) && NotEquals(weaponRecData.ItemType().Type(), gamedataItemType.Cyb_NanoWires);
    if NotEquals(weaponRecData.Evolution().Type(), gamedataWeaponEvolution.Smart) && !isInvalidMeleeWeapon {
      if this.m_weapon.IsRanged() {
        userSettings = GameInstance.GetSettingsSystem(this.m_weapon.GetGame());
        settingGroup = userSettings.GetGroup(n"/gameplay/difficulty");
        aimSnapSetting = settingGroup.GetVar(n"AimSnap") as ConfigVarBool;
        if IsDefined(aimSnapSetting) {
          aimSnapEnabledInSetting = aimSnapSetting.GetValue();
        };
      };
      if aimSnapEnabledInSetting {
        if scriptInterface.GetTransactionSystem().HasTag(scriptInterface.executionOwner, n"PerfectAim", this.m_weapon.GetItemID()) {
          perfectAimSnapParams = this.GetPerfectAimSnapParams();
          scriptInterface.GetTargetingSystem().LookAt(scriptInterface.owner, perfectAimSnapParams);
        } else {
          scriptInterface.GetTargetingSystem().AimSnap(scriptInterface.owner);
        };
      };
    };
  }

  protected final func GetVehicleAimSnapParams() -> AimRequest {
    let aimSnapParams: AimRequest;
    aimSnapParams.duration = 0.25;
    aimSnapParams.adjustPitch = true;
    aimSnapParams.adjustYaw = true;
    aimSnapParams.endOnTargetReached = false;
    aimSnapParams.endOnCameraInputApplied = true;
    aimSnapParams.endOnTimeExceeded = false;
    aimSnapParams.cameraInputMagToBreak = 0.50;
    aimSnapParams.precision = 0.10;
    aimSnapParams.maxDuration = 0.00;
    aimSnapParams.easeIn = true;
    aimSnapParams.easeOut = true;
    aimSnapParams.checkRange = true;
    aimSnapParams.processAsInput = true;
    return aimSnapParams;
  }

  protected final func GetPerfectAimSnapParams() -> AimRequest {
    let aimSnapParams: AimRequest;
    aimSnapParams.duration = 0.25;
    aimSnapParams.adjustPitch = true;
    aimSnapParams.adjustYaw = true;
    aimSnapParams.endOnAimingStopped = true;
    aimSnapParams.precision = 0.10;
    aimSnapParams.easeIn = true;
    aimSnapParams.easeOut = true;
    aimSnapParams.checkRange = true;
    aimSnapParams.processAsInput = true;
    aimSnapParams.bodyPartsTracking = true;
    aimSnapParams.bptMaxDot = 0.50;
    aimSnapParams.bptMaxSwitches = -1.00;
    aimSnapParams.bptMinInputMag = 0.50;
    aimSnapParams.bptMinResetInputMag = 0.10;
    return aimSnapParams;
  }

  protected final func UpdateAimAnimFeature(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let stats: ref<StatsSystem>;
    if stateContext.GetBoolParameter(n"WeaponInSafe", true) && !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneAimForced) {
      this.m_aim.SetAimState(animAimState.Unaimed);
    } else {
      this.m_aim.SetAimState(animAimState.Aimed);
    };
    stats = scriptInterface.GetStatsSystem();
    this.m_aim.SetZoomState(animAimState.Aimed);
    this.m_aim.SetAimInTime(stats.GetStatValue(Cast(this.m_weapon.GetEntityID()), gamedataStatType.AimInTime));
    this.m_aim.SetAimOutTime(stats.GetStatValue(Cast(this.m_weapon.GetEntityID()), gamedataStatType.AimOutTime));
    scriptInterface.SetAnimationParameterFeature(n"AnimFeature_AimPlayer", this.m_aim);
    scriptInterface.SetAnimationParameterFeature(n"AnimFeature_AimPlayer", this.m_aim, this.m_weapon);
  }

  protected final func UpdateAimDownSightsSfx(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if stateContext.GetBoolParameter(n"WeaponInSafe", true) {
      if this.m_isAiming {
        this.m_isAiming = false;
        this.ToggleAudioAimDownSights(this.m_weapon, this.m_isAiming);
      };
    } else {
      if !this.m_isAiming {
        this.m_isAiming = true;
        this.ToggleAudioAimDownSights(this.m_weapon, this.m_isAiming);
      };
    };
  }

  protected final func UpdateZoomVfx(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.m_finalZoomLevel >= 2.00 {
      this.StartZoomEffect(scriptInterface, n"zoom");
    } else {
      this.BreakEffectLoop(scriptInterface, n"zoom");
    };
  }

  protected final func StartZoomEffect(scriptInterface: ref<StateGameScriptInterface>, effectName: CName) -> Void {
    let maxZoom: Float = this.GetStaticFloatParameterDefault("noWeaponZoomLevel" + "" + this.m_numZoomLevels, 1.00);
    let normalizedZoom: Float = this.m_finalZoomLevel / maxZoom;
    let blackboard: ref<worldEffectBlackboard> = new worldEffectBlackboard();
    blackboard.SetValue(n"zoomValue", normalizedZoom);
    GameObjectEffectHelper.StartEffectEvent(scriptInterface.owner, n"zoom", false, blackboard);
  }

  protected final func UpdateWeaponOffsetPosition(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let addedPosition: Vector3;
    let stats: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    this.m_posAnimFeature.isEnabled = this.m_weapon.GetWeaponRecord().IsIKEnabled();
    this.m_posAnimFeature.hasScope = this.m_weapon.HasScope();
    if this.m_posAnimFeature.hasScope {
      this.m_posAnimFeature.position = this.m_weapon.GetScopeOffset();
    } else {
      this.m_posAnimFeature.position = this.m_weapon.GetIronSightOffset();
    };
    addedPosition = this.m_weapon.GetWeaponRecord().IkOffset();
    this.m_posAnimFeature.position += Vector4.Vector3To4(addedPosition);
    this.m_posAnimFeature.offset = stats.GetStatValue(Cast(this.m_weapon.GetEntityID()), gamedataStatType.AimOffset);
    this.m_posAnimFeature.scopeOffset = stats.GetStatValue(Cast(this.m_weapon.GetEntityID()), gamedataStatType.ScopeOffset);
    scriptInterface.SetAnimationParameterFeature(n"ProceduralIronsightData", this.m_posAnimFeature);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let weapon: ref<WeaponObject>;
    this.OnExit(stateContext, scriptInterface);
    weapon = this.GetWeaponObject(scriptInterface);
    this.m_aim.SetAimState(animAimState.Unaimed);
    this.m_aim.SetZoomState(animAimState.Unaimed);
    this.m_isAiming = false;
    scriptInterface.SetAnimationParameterFeature(n"AnimFeature_AimPlayer", this.m_aim);
    scriptInterface.SetAnimationParameterFeature(n"AnimFeature_AimPlayer", this.m_aim, weapon);
    if !stateContext.GetBoolParameter(n"WeaponInSafe", true) {
      this.TriggerZoomExitSfx(scriptInterface);
    };
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UpperBody, EnumInt(gamePSMUpperBodyStates.Default));
    scriptInterface.GetTargetingSystem().OnAimStop(scriptInterface.owner);
    this.BreakEffectLoopOnHeldItems(scriptInterface, n"lightswitch");
    broadcaster = scriptInterface.owner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      this.m_aimBroadcast = false;
      broadcaster.RemoveActiveStimuliByName(scriptInterface.owner, gamedataStimType.CrowdIllegalAction);
    };
    this.NotifyWeaponObject(scriptInterface, false);
  }

  protected final func TriggerZoomExitSfx(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ToggleAudioAimDownSights(DefaultTransition.GetActiveWeapon(scriptInterface), this.m_isAiming);
  }

  protected final func NotifyWeaponObject(scriptInterface: ref<StateGameScriptInterface>, isAiming: Bool) -> Void {
    let evt: ref<gameweaponeventsOwnerAimEvent>;
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    if IsDefined(weapon) {
      evt = new gameweaponeventsOwnerAimEvent();
      evt.isAiming = isAiming;
      weapon.QueueEvent(evt);
    };
  }
}

public class TemporaryUnequipDecisions extends UpperBodyTransition {

  protected final const func IsTemporaryUnequipRequested(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let locomotionDetailedState: Int32;
    if stateContext.GetBoolParameter(n"forcedTemporaryUnequip", true) || stateContext.GetBoolParameter(n"forceTempUnequipWeapon", true) {
      return true;
    };
    if Equals(this.GetLocomotionState(stateContext), n"workspot") {
      if DefaultTransition.GetPlayerPuppet(scriptInterface).HasWorkspotTag(n"Grab") {
        return true;
      };
    };
    locomotionDetailedState = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed);
    if locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.Climb) || locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.Ladder) || locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.LadderSprint) || locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.LadderSlide) || locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.VeryHardLand) {
      return true;
    };
    if this.IsInHighLevelState(stateContext, n"swimming") {
      return true;
    };
    if scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice) || scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsControllingDevice) {
      return true;
    };
    return false;
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsTemporaryUnequipRequested(stateContext, scriptInterface);
  }

  protected const func ToWaitForEquip(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsTemporaryUnequipRequested(stateContext, scriptInterface) || stateContext.GetBoolParameter(n"cgCached", true) || scriptInterface.GetActionValue(n"UseCombatGadget") != 0.00 && !stateContext.GetBoolParameter(n"invalidTempUnequipThrow", true) || !stateContext.GetConditionBool(n"TemporaryUnequipHasUnequippedWeapon") {
      if !stateContext.GetBoolParameter(n"ChargeCancelled", true) {
        return false;
      };
    };
    if this.IsInLocomotionState(stateContext, n"knockdown") || StatusEffectSystem.ObjectHasStatusEffectOfType(scriptInterface.executionOwner, gamedataStatusEffectType.Knockdown) {
      return false;
    };
    return !IsDefined(this.GetItemInRightHandSlot(scriptInterface));
  }

  protected final const func ToEmptyHands(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.GetBoolParameter(n"cgCached", true) || scriptInterface.GetActionValue(n"UseCombatGadget") != 0.00 && !stateContext.GetBoolParameter(n"invalidTempUnequipThrow", true) || this.IsTemporaryUnequipRequested(stateContext, scriptInterface) {
      if !stateContext.GetBoolParameter(n"ChargeCancelled", true) {
        return false;
      };
    };
    return !stateContext.GetConditionBool(n"TemporaryUnequipHasUnequippedWeapon");
  }

  protected final const func ToSingleWield(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.GetBoolParameter(n"cgCached", true) || scriptInterface.GetActionValue(n"UseCombatGadget") != 0.00 && !stateContext.GetBoolParameter(n"invalidTempUnequipThrow", true) {
      if !stateContext.GetBoolParameter(n"ChargeCancelled", true) {
        return false;
      };
    };
    return !this.IsTemporaryUnequipRequested(stateContext, scriptInterface) && IsDefined(this.GetItemInRightHandSlot(scriptInterface));
  }
}

public class TemporaryUnequipEvents extends UpperBodyEventsTransition {

  private let m_forceOpen: Bool;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let equipAnimType: gameEquipAnimationType;
    let isInInstantEquipPSMState: Bool;
    let locomotionDetailedState: Int32;
    this.m_forceOpen = false;
    this.ResetEquipVars(stateContext);
    if !this.IsRightHandInUnequippedState(stateContext) || !this.IsLeftHandInUnequippedState(stateContext) {
      equipAnimType = gameEquipAnimationType.Instant;
      locomotionDetailedState = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed);
      isInInstantEquipPSMState = locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.Climb) || locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.Ladder) || locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.LadderSprint) || locomotionDetailedState == EnumInt(gamePSMDetailedLocomotionStates.LadderSlide) || scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel) == EnumInt(gamePSMHighLevel.Swimming);
      if isInInstantEquipPSMState || stateContext.GetBoolParameter(n"forcedTemporaryUnequip", true) {
        equipAnimType = gameEquipAnimationType.Instant;
      } else {
        equipAnimType = gameEquipAnimationType.Default;
      };
      if stateContext.GetBoolParameter(n"forceTempUnequipWeapon", true) {
        this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipWeapon, equipAnimType);
      } else {
        this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.UnequipAll, equipAnimType);
      };
      stateContext.SetConditionBoolParameter(n"TemporaryUnequipHasUnequippedWeapon", true, true);
    } else {
      stateContext.SetConditionBoolParameter(n"TemporaryUnequipHasUnequippedWeapon", false, true);
      stateContext.RemovePermanentBoolParameter(n"ChargeCancelled");
    };
  }

  protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let locomotionState: CName;
    if scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsForceOpeningDoor) {
      if !this.m_forceOpen {
        this.ForceEquipStrongArms(scriptInterface.executionOwner as PlayerPuppet);
      };
      stateContext.SetPermanentBoolParameter(n"invalidTempUnequipThrow", true, true);
      return;
    };
    locomotionState = this.GetLocomotionState(stateContext);
    if Equals(locomotionState, n"climb") || Equals(locomotionState, n"ladder") || Equals(locomotionState, n"ladderSprint") || Equals(locomotionState, n"ladderSlide") || Equals(locomotionState, n"veryHardLand") || Equals(locomotionState, n"knockdown") || Equals(locomotionState, n"vehicleKnockdown") || Equals(locomotionState, n"forcedKnockdown") || this.IsInHighLevelState(stateContext, n"swimming") || this.IsInTakedownState(stateContext) || scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice) || StatusEffectSystem.ObjectHasStatusEffectOfType(scriptInterface.executionOwner, gamedataStatusEffectType.Knockdown) || stateContext.IsStateMachineActive(n"LeftHandCyberware") {
      stateContext.SetPermanentBoolParameter(n"invalidTempUnequipThrow", true, true);
      return;
    };
    this.ProcessCombatGadgetActionInputCaching(scriptInterface, stateContext);
    if this.GetCancelChargeButtonInput(scriptInterface) && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.CombatGadget) == EnumInt(gamePSMCombatGadget.Charging) && stateContext.IsStateMachineActive(n"CombatGadget") || stateContext.IsStateMachineActive(n"LeftHandCyberware") {
      stateContext.SetPermanentBoolParameter(n"ChargeCancelled", true, true);
    } else {
      if stateContext.GetBoolParameter(n"ChargeCancelled", true) && !stateContext.IsStateMachineActive(n"CombatGadget") && !stateContext.IsStateMachineActive(n"LeftHandCyberware") {
        stateContext.RemovePermanentBoolParameter(n"ChargeCancelled");
      };
    };
    if (scriptInterface.IsActionJustPressed(n"UseCombatGadget") || stateContext.GetBoolParameter(n"cgCached", true)) && this.IsLeftHandInUnequippedState(stateContext) {
      if this.IsUsingLeftHandAllowed(scriptInterface) && !stateContext.IsStateMachineActive(n"Consumable") && !this.IsInUpperBodyState(stateContext, n"forceEmptyHands") && !this.AreChoiceHubsActive(scriptInterface) && !this.IsInSafeZone(scriptInterface) && !DefaultTransition.IsInWorkspot(scriptInterface) {
        if this.CheckItemCategoryInQuickWheel(scriptInterface, gamedataItemCategory.Gadget) {
          this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestGadget);
          stateContext.SetPermanentBoolParameter(n"forceTempUnequipWeapon", true, true);
          stateContext.SetPermanentBoolParameter(n"gadgetRequested", true, true);
        } else {
          if this.CheckItemCategoryInQuickWheel(scriptInterface, gamedataItemCategory.Cyberware) {
            this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.RequestGadget);
            stateContext.RemovePermanentBoolParameter(n"cgCached");
            stateContext.SetPermanentBoolParameter(n"gadgetRequested", true, true);
          };
        };
      };
    };
    if stateContext.GetBoolParameter(n"gadgetRequested", true) && scriptInterface.GetActionValue(n"UseCombatGadget") == 0.00 && !stateContext.GetBoolParameter(n"cgCached", true) && !stateContext.IsStateMachineActive(n"CombatGadget") && !stateContext.IsStateMachineActive(n"LeftHandCyberware") {
      stateContext.RemovePermanentBoolParameter(n"forceTempUnequipWeapon");
    };
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.UpperBody, EnumInt(gamePSMUpperBodyStates.Default));
    if this.m_forceOpen {
      this.ForceUnequipStrongArms(scriptInterface.executionOwner as PlayerPuppet);
    };
    stateContext.RemovePermanentBoolParameter(n"ChargeCancelled");
    stateContext.RemovePermanentBoolParameter(n"invalidTempUnequipThrow");
    stateContext.RemovePermanentBoolParameter(n"gadgetRequested");
  }

  protected final func ForceEquipStrongArms(player: ref<PlayerPuppet>) -> Void {
    if RPGManager.ForceEquipStrongArms(player) {
      this.m_forceOpen = true;
    };
  }

  protected final func ForceUnequipStrongArms(player: ref<PlayerPuppet>) -> Void {
    RPGManager.ForceUnequipStrongArms(player);
  }
}

public class WaitForEquipDecisions extends UpperBodyTransition {

  protected const func ToSingleWield(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return IsDefined(DefaultTransition.GetActiveWeapon(scriptInterface));
  }

  protected final const func ToEmptyHands(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() > 2.00;
  }
}

public class WaitForEquipEvents extends UpperBodyEventsTransition {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SendEquipmentSystemWeaponManipulationRequest(scriptInterface, EquipmentManipulationAction.ReequipWeapon);
  }
}

public class AdHocAnimationDecisions extends UpperBodyEventsTransition {

  protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let blackboardSystem: ref<BlackboardSystem> = scriptInterface.GetBlackboardSystem();
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().AdHocAnimation);
    if blackboard.GetBool(GetAllBlackboardDefs().AdHocAnimation.IsActive) {
      return true;
    };
    return false;
  }

  protected const func ToSingleWield(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() > this.GetStaticFloatParameterDefault("animDuration", 2.00) && DefaultTransition.HasRightWeaponEquipped(scriptInterface) {
      return true;
    };
    return false;
  }

  protected const func ToEmptyHands(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetInStateTime() > this.GetStaticFloatParameterDefault("animDuration", 2.00) && !DefaultTransition.HasRightWeaponEquipped(scriptInterface) {
      return true;
    };
    return false;
  }
}

public class AdHocAnimationEvents extends TemporaryUnequipEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let blackboardSystem: ref<BlackboardSystem> = scriptInterface.GetBlackboardSystem();
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().AdHocAnimation);
    let adHocFeature: ref<AnimFeature_AdHocAnimation> = new AnimFeature_AdHocAnimation();
    adHocFeature.useBothHands = true;
    adHocFeature.isActive = true;
    adHocFeature.animationIndex = blackboard.GetInt(GetAllBlackboardDefs().AdHocAnimation.AnimationIndex);
    if !blackboard.GetBool(GetAllBlackboardDefs().AdHocAnimation.UseBothHands) {
      adHocFeature.useBothHands = false;
    };
    if blackboard.GetBool(GetAllBlackboardDefs().AdHocAnimation.UnequipWeapon) {
      this.OnEnter(stateContext, scriptInterface);
    };
    scriptInterface.SetAnimationParameterFeature(n"AdHoc", adHocFeature);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let adHocFeature: ref<AnimFeature_AdHocAnimation>;
    let blackboardSystem: ref<BlackboardSystem> = scriptInterface.GetBlackboardSystem();
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().AdHocAnimation);
    if blackboard.GetBool(GetAllBlackboardDefs().AdHocAnimation.UnequipWeapon) {
      this.OnExit(stateContext, scriptInterface);
    };
    adHocFeature = new AnimFeature_AdHocAnimation();
    adHocFeature.isActive = false;
    scriptInterface.SetAnimationParameterFeature(n"AdHoc", adHocFeature);
    blackboard.SetBool(GetAllBlackboardDefs().AdHocAnimation.IsActive, false);
  }
}
