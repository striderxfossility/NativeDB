
public class HotkeyWidgetStatsListener extends ScriptStatusEffectListener {

  private let m_controller: wref<GenericHotkeyController>;

  public final func Init(controller: ref<GenericHotkeyController>) -> Void {
    this.m_controller = controller;
  }

  public func OnStatusEffectApplied(statusEffect: wref<StatusEffect_Record>) -> Void {
    this.m_controller.OnRestrictionUpdate(statusEffect);
  }

  public func OnStatusEffectRemoved(statusEffect: wref<StatusEffect_Record>) -> Void {
    this.m_controller.OnRestrictionUpdate(statusEffect);
  }
}

public abstract class GenericHotkeyController extends inkHUDGameController {

  protected edit let m_hotkeyBackground: inkImageRef;

  protected edit let m_buttonHint: inkWidgetRef;

  protected edit let m_hotkey: EHotkey;

  protected let m_pressStarted: Bool;

  private let m_buttonHintController: wref<inkInputDisplayController>;

  private let m_questActivatingFact: CName;

  protected let m_restrictions: array<CName>;

  protected let m_statusEffectsListener: ref<HotkeyWidgetStatsListener>;

  private let debugCommands: array<Uint32>;

  private let m_factListenerId: Uint32;

  protected cb func OnInitialize() -> Bool {
    this.Initialize();
  }

  protected cb func OnUninitialize() -> Bool {
    this.Uninitialize();
  }

  protected func Initialize() -> Bool {
    let mainPlayer: wref<GameObject>;
    if Equals(this.m_hotkey, EHotkey.INVALID) {
      return false;
    };
    switch this.m_hotkey {
      case EHotkey.DPAD_UP:
        this.m_questActivatingFact = n"dpad_hints_visibility_enabled";
        break;
      case EHotkey.DPAD_DOWN:
        this.m_questActivatingFact = n"unlock_phone_hud_dpad";
        break;
      case EHotkey.DPAD_RIGHT:
        this.m_questActivatingFact = n"unlock_car_hud_dpad";
        break;
      case EHotkey.RB:
        this.m_questActivatingFact = n"initial_gadget_picked";
    };
    this.m_factListenerId = GameInstance.GetQuestsSystem(this.GetPlayer().GetGame()).RegisterListener(this.m_questActivatingFact, this, n"OnActivation");
    PlayerGameplayRestrictions.AcquireHotkeyRestrictionTags(this.m_hotkey, this.m_restrictions);
    this.m_statusEffectsListener = new HotkeyWidgetStatsListener();
    this.m_statusEffectsListener.Init(this);
    mainPlayer = GameInstance.GetPlayerSystem(this.GetPlayer().GetGame()).GetLocalPlayerMainGameObject();
    GameInstance.GetStatusEffectSystem(this.GetPlayer().GetGame()).RegisterListener(mainPlayer.GetEntityID(), this.m_statusEffectsListener);
    this.m_buttonHintController = inkWidgetRef.Get(this.m_buttonHint).GetController() as inkInputDisplayController;
    this.InitializeButtonHint();
    this.ResolveState();
    return true;
  }

  protected func Uninitialize() -> Void {
    GameInstance.GetQuestsSystem(this.GetPlayer().GetGame()).UnregisterListener(this.m_questActivatingFact, this.m_factListenerId);
    this.m_statusEffectsListener = null;
  }

  private final func InitializeButtonHint() -> Void {
    if Equals(this.m_hotkey, EHotkey.RB) {
      this.m_buttonHintController.SetInputAction(n"UseCombatGadget");
      this.m_buttonHintController.SetHoldIndicatorType(inkInputHintHoldIndicationType.FromInputConfig);
    } else {
      if Equals(this.m_hotkey, EHotkey.DPAD_UP) {
        this.m_buttonHintController.SetInputAction(n"UseConsumable");
        this.m_buttonHintController.SetHoldIndicatorType(inkInputHintHoldIndicationType.Press);
      } else {
        if Equals(this.m_hotkey, EHotkey.DPAD_DOWN) {
          this.m_buttonHintController.SetInputAction(n"PhoneInteract");
          this.m_buttonHintController.SetHoldIndicatorType(inkInputHintHoldIndicationType.FromInputConfig);
        } else {
          if Equals(this.m_hotkey, EHotkey.DPAD_RIGHT) {
            this.m_buttonHintController.SetInputAction(n"CallVehicle");
            this.m_buttonHintController.SetHoldIndicatorType(inkInputHintHoldIndicationType.FromInputConfig);
          };
        };
      };
    };
  }

  protected final func GetPlayer() -> wref<PlayerPuppet> {
    return this.GetPlayerControlledObject() as PlayerPuppet;
  }

  protected final func ResolveState() -> Void {
    if this.IsInDefaultState() {
      this.GetRootWidget().SetState(n"Default");
    } else {
      this.GetRootWidget().SetState(n"Unavailable");
    };
  }

  protected final func IsInDefaultState() -> Bool {
    return this.IsActivatedByQuest() && this.IsAllowedByGameplay();
  }

  protected final func IsActivatedByQuest() -> Bool {
    let val: Int32;
    let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetPlayerControlledObject().GetGame());
    if IsDefined(qs) {
      val = qs.GetFact(this.m_questActivatingFact);
      return val >= 1 ? true : false;
    };
    return false;
  }

  protected func IsAllowedByGameplay() -> Bool {
    return !StatusEffectSystem.ObjectHasStatusEffectWithTags(this.GetPlayer(), this.m_restrictions);
  }

  public final func OnRestrictionUpdate(statusEffect: wref<StatusEffect_Record>) -> Void {
    this.ResolveState();
  }

  protected cb func OnDpadActionPerformed(evt: ref<DPADActionPerformed>) -> Bool {
    let animName: CName;
    if Equals(this.m_hotkey, evt.action) {
      if evt.successful && this.IsInDefaultState() {
        animName = StringToName("onUse_" + EnumValueToString("EHotkey", EnumInt(evt.action)));
        this.PlayLibraryAnimation(animName);
      } else {
        animName = StringToName("onFailUse_" + EnumValueToString("EHotkey", EnumInt(evt.action)));
        this.PlayLibraryAnimation(animName);
      };
    };
  }

  protected final func DBGPlayAnim(animName: CName) -> Void {
    if Equals(animName, n"onStarted_DPAD_RIGHT") {
      1 + 1;
    };
    this.PlayLibraryAnimation(animName);
    ArrayPush(this.debugCommands, GameInstance.GetDebugVisualizerSystem(this.GetPlayer().GetGame()).DrawText(new Vector4(600.00, 900.00 - 20.00 * Cast(ArraySize(this.debugCommands)), 0.00, 0.00), NameToString(animName)));
  }

  public final func OnActivation(value: Int32) -> Void {
    this.ResolveState();
  }
}

public class PhoneHotkeyController extends GenericHotkeyController {

  private edit let mainIcon: inkImageRef;

  private edit let messagePrompt: inkTextRef;

  private edit let messageCounter: inkTextRef;

  private let journalManager: wref<JournalManager>;

  @default(PhoneHotkeyController, base\gameplay\gui\common\icons\atlas_common.inkatlas)
  private let phoneIconAtlas: String;

  @default(PhoneHotkeyController, ico_phone)
  private let phoneIconName: CName;

  protected func Initialize() -> Bool {
    this.Initialize();
    this.journalManager = GameInstance.GetJournalManager(this.GetPlayer().GetGame());
    if !IsDefined(this.journalManager) {
      return false;
    };
    this.journalManager.RegisterScriptCallback(this, n"OnJournalUpdate", gameJournalListenerType.State);
    this.journalManager.RegisterScriptCallback(this, n"OnJournalUpdateVisited", gameJournalListenerType.Visited);
    this.UpdateData();
    return true;
  }

  protected func Uninitialize() -> Void {
    this.Uninitialize();
    if IsDefined(this.journalManager) {
      this.journalManager.UnregisterScriptCallback(this, n"OnJournalUpdate");
      this.journalManager.UnregisterScriptCallback(this, n"OnJournalUpdateVisited");
      this.journalManager = null;
    };
  }

  private final func UpdateData() -> Void {
    let contacts: array<wref<JournalEntry>>;
    let context: JournalRequestContext;
    let dump: array<wref<JournalEntry>>;
    let i: Int32;
    let j: Int32;
    let messages: array<wref<JournalEntry>>;
    let unreadMessages: Int32;
    if !IsDefined(this.journalManager) {
      return;
    };
    unreadMessages = 0;
    context.stateFilter.active = true;
    this.journalManager.GetContacts(context, contacts);
    i = 0;
    while i < ArraySize(contacts) {
      if IsDefined(contacts[i]) {
        this.journalManager.GetFlattenedMessagesAndChoices(contacts[i], messages, dump);
        j = 0;
        while j < ArraySize(messages) {
          if IsDefined(messages[j]) && !this.journalManager.IsEntryVisited(messages[j]) {
            unreadMessages += 1;
          };
          j += 1;
        };
      };
      i += 1;
    };
    if unreadMessages == 0 {
      inkWidgetRef.SetVisible(this.messageCounter, false);
    } else {
      inkWidgetRef.SetVisible(this.messageCounter, true);
      inkTextRef.SetText(this.messageCounter, IntToString(unreadMessages));
    };
  }

  protected cb func OnJournalUpdate(entryHash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    if Equals(className, n"gameJournalPhoneMessage") {
      this.NewMassagePrompt();
      this.UpdateData();
    };
  }

  protected cb func OnJournalUpdateVisited(entryHash: Uint32, className: CName, notifyOption: JournalNotifyOption, changeType: JournalChangeType) -> Bool {
    if Equals(className, n"gameJournalPhoneMessage") {
      this.UpdateData();
    };
  }

  protected cb func OnMessagePromptFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.RestoreDefaultIcon();
  }

  protected func IsAllowedByGameplay() -> Bool {
    return !HUDManager.IsQuickHackPanelOpen(this.GetPlayer().GetGame()) && this.IsAllowedByGameplay();
  }

  private final func NewMassagePrompt() -> Void {
    let animProxy: ref<inkAnimProxy>;
    inkWidgetRef.SetVisible(this.mainIcon, false);
    inkWidgetRef.SetVisible(this.messagePrompt, true);
    animProxy = this.PlayLibraryAnimation(n"message_prompt");
    animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnMessagePromptFinished");
  }

  private final func RestoreDefaultIcon() -> Void {
    inkWidgetRef.SetVisible(this.messagePrompt, false);
    inkWidgetRef.SetVisible(this.mainIcon, true);
  }

  protected cb func OnDpadActionPerformed(evt: ref<DPADActionPerformed>) -> Bool {
    let animName: CName;
    if Equals(this.m_hotkey, evt.action) {
      if !this.IsInDefaultState() {
        animName = StringToName("aborted_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
        this.PlayLibraryAnimation(animName);
        animName = StringToName("onFailUse_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
        this.PlayLibraryAnimation(animName);
        return false;
      };
      if Equals(evt.state, EUIActionState.STARTED) {
        this.m_pressStarted = true;
        animName = StringToName("started_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
        this.PlayLibraryAnimation(animName);
      } else {
        if Equals(evt.state, EUIActionState.ABORTED) && this.m_pressStarted {
          animName = StringToName("aborted_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
          this.PlayLibraryAnimation(animName);
        } else {
          if Equals(evt.state, EUIActionState.COMPLETED) && evt.successful {
            animName = StringToName("onUse_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
            this.PlayLibraryAnimation(animName);
          } else {
            if !evt.successful {
              animName = StringToName("aborted_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
              this.PlayLibraryAnimation(animName);
              animName = StringToName("onFailUse_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
              this.PlayLibraryAnimation(animName);
            };
          };
        };
      };
    };
  }
}

public class CarHotkeyController extends GenericHotkeyController {

  private edit let carIconSlot: inkImageRef;

  private let vehicleSystem: wref<VehicleSystem>;

  private let psmBB: wref<IBlackboard>;

  private let bbListener: ref<CallbackHandle>;

  protected func Initialize() -> Bool {
    this.Initialize();
    this.vehicleSystem = GameInstance.GetVehicleSystem(this.GetPlayer().GetGame());
    this.psmBB = GameInstance.GetBlackboardSystem(this.GetPlayer().GetGame()).Get(GetAllBlackboardDefs().PlayerStateMachine);
    if !IsDefined(this.vehicleSystem) || !IsDefined(this.psmBB) {
      return false;
    };
    this.bbListener = this.psmBB.RegisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle, this, n"OnPlayerEnteredVehicle", true);
    return true;
  }

  protected func Uninitialize() -> Void {
    this.Uninitialize();
    if IsDefined(this.bbListener) {
      this.psmBB.UnregisterListenerInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle, this.bbListener);
    };
  }

  protected cb func OnDpadActionPerformed(evt: ref<DPADActionPerformed>) -> Bool {
    let animName: CName;
    if Equals(this.m_hotkey, evt.action) {
      if !this.IsInDefaultState() {
        animName = StringToName("aborted_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
        this.PlayLibraryAnimation(animName);
        animName = StringToName("onFailUse_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
        this.PlayLibraryAnimation(animName);
        return false;
      };
      if Equals(evt.state, EUIActionState.STARTED) {
        animName = StringToName("started_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
        this.PlayLibraryAnimation(animName);
      } else {
        if Equals(evt.state, EUIActionState.ABORTED) {
          animName = StringToName("aborted_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
          this.PlayLibraryAnimation(animName);
        } else {
          if Equals(evt.state, EUIActionState.COMPLETED) && evt.successful {
            animName = StringToName("onUse_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
            this.PlayLibraryAnimation(animName);
          } else {
            if !evt.successful {
              animName = StringToName("aborted_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
              this.PlayLibraryAnimation(animName);
              animName = StringToName("onFailUse_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
              this.PlayLibraryAnimation(animName);
            };
          };
        };
      };
    };
  }

  protected cb func OnPlayerEnteredVehicle(value: Int32) -> Bool {
    this.ResolveState();
  }

  protected func IsAllowedByGameplay() -> Bool {
    if !VehicleSystem.IsSummoningVehiclesRestricted(this.GetPlayer().GetGame()) {
      return true;
    };
    return false;
  }
}

public class HotkeyItemController extends GenericHotkeyController {

  protected edit let m_hotkeyItemSlot: inkWidgetRef;

  private let m_hotkeyItemController: wref<InventoryItemDisplayController>;

  private let m_currentItem: InventoryItemData;

  private let m_hotkeyBlackboard: wref<IBlackboard>;

  private let m_hotkeyCallbackID: ref<CallbackHandle>;

  private let m_equipmentSystem: wref<EquipmentSystem>;

  private let m_inventoryManager: ref<InventoryDataManagerV2>;

  protected func Initialize() -> Bool {
    let qs: ref<QuestsSystem>;
    let initSuccessful: Bool = this.Initialize();
    if !initSuccessful {
      return false;
    };
    this.m_hotkeyItemController = this.SpawnFromLocal(inkWidgetRef.Get(this.m_hotkeyItemSlot), n"HotkeyItem").GetController() as InventoryItemDisplayController;
    this.m_equipmentSystem = this.GetEquipmentSystem();
    qs = GameInstance.GetQuestsSystem(this.GetPlayerControlledObject().GetGame());
    if !IsDefined(this.m_hotkeyItemController) || !IsDefined(this.m_equipmentSystem) || !IsDefined(qs) {
      return false;
    };
    this.m_inventoryManager = new InventoryDataManagerV2();
    this.m_inventoryManager.Initialize(this.GetPlayer(), this);
    this.m_hotkeyBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Hotkeys);
    if IsDefined(this.m_hotkeyBlackboard) {
      this.m_hotkeyCallbackID = this.m_hotkeyBlackboard.RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_Hotkeys.ModifiedHotkey, this, n"OnHotkeyRefreshed");
    };
    this.InitializeHotkeyItem();
    return true;
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.InitializeHotkeyItem();
  }

  private final func InitializeHotkeyItem() -> Void {
    this.m_hotkeyItemController.Setup(this.m_inventoryManager.GetHotkeyItemData(this.m_hotkey), ItemDisplayContext.DPAD_RADIAL);
  }

  protected func Uninitialize() -> Void {
    this.Uninitialize();
    this.m_inventoryManager.UnInitialize();
    if IsDefined(this.m_hotkeyBlackboard) {
      this.m_hotkeyBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().UI_Hotkeys.ModifiedHotkey, this.m_hotkeyCallbackID);
      this.m_hotkeyBlackboard = null;
    };
  }

  protected func IsAllowedByGameplay() -> Bool {
    return this.IsAllowedByGameplay();
  }

  protected cb func OnDpadActionPerformed(evt: ref<DPADActionPerformed>) -> Bool {
    let animName: CName;
    if Equals(this.m_hotkey, evt.action) {
      if !this.IsInDefaultState() {
        animName = StringToName("aborted_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
        this.PlayLibraryAnimation(animName);
        animName = StringToName("onFailUse_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
        this.PlayLibraryAnimation(animName);
        return false;
      };
      if Equals(evt.state, EUIActionState.STARTED) {
        animName = StringToName("started_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
        this.PlayLibraryAnimation(animName);
      } else {
        if Equals(evt.state, EUIActionState.ABORTED) {
          animName = StringToName("aborted_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
          this.PlayLibraryAnimation(animName);
        } else {
          if Equals(evt.state, EUIActionState.COMPLETED) && evt.successful {
            animName = StringToName("onUse_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
            this.PlayLibraryAnimation(animName);
          } else {
            if !evt.successful {
              animName = StringToName("aborted_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
              this.PlayLibraryAnimation(animName);
              animName = StringToName("onFailUse_" + EnumValueToString("EHotkey", EnumInt(this.m_hotkey)));
              this.PlayLibraryAnimation(animName);
            };
          };
        };
      };
    };
  }

  protected cb func OnHotkeyRefreshed(value: Variant) -> Bool {
    let hotkey: EHotkey = FromVariant(value);
    if NotEquals(hotkey, this.m_hotkey) {
      return false;
    };
    this.m_currentItem = this.m_inventoryManager.GetHotkeyItemData(this.m_hotkey);
    this.m_hotkeyItemController.Setup(this.m_currentItem, ItemDisplayContext.DPAD_RADIAL);
  }

  public final func OnQuestActivate(value: Int32) -> Void {
    if value > 0 {
      this.GetRootWidget().SetState(n"Default");
    } else {
      this.GetRootWidget().SetState(n"Unavailable");
    };
  }

  private final func GetEquipmentSystem() -> wref<EquipmentSystem> {
    if !IsDefined(this.m_equipmentSystem) {
      this.m_equipmentSystem = GameInstance.GetScriptableSystemsContainer(this.GetPlayerControlledObject().GetGame()).Get(n"EquipmentSystem") as EquipmentSystem;
    };
    return this.m_equipmentSystem;
  }
}
