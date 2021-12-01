
public class QuickhackModule extends HUDModule {

  private let m_calculateClose: Bool;

  public final func SetCalculateClose(value: Bool) -> Void {
    this.m_calculateClose = value;
  }

  public const func IsModuleOperational() -> Bool {
    if this.m_hud.IsBraindanceActive() {
      return false;
    };
    if this.m_hud.IsQuickHackPanelOpened() && NotEquals(this.m_hud.GetActiveMode(), ActiveMode.FOCUS) {
      return true;
    };
    if Equals(this.m_hud.GetActiveMode(), ActiveMode.FOCUS) {
      return true;
    };
    return false;
  }

  protected func Process(out task: HUDJob, mode: ActiveMode) -> Void {
    let instruction: ref<QuickhackInstance>;
    if !IsDefined(task.actor) {
      return;
    };
    if IsDefined(this.m_hud.GetCurrentTarget()) && (Equals(this.m_hud.GetCurrentTarget().GetType(), HUDActorType.DEVICE) || Equals(this.m_hud.GetCurrentTarget().GetType(), HUDActorType.BODY_DISPOSAL_DEVICE) || Equals(this.m_hud.GetCurrentTarget().GetType(), HUDActorType.PUPPET)) {
      if task.actor == this.m_hud.GetCurrentTarget() {
        if this.m_hud.GetCurrentTarget().GetShouldRefreshQHack() {
          this.m_calculateClose = true;
          this.m_hud.GetCurrentTarget().SetShouldRefreshQHack(false);
          instruction = task.instruction.quickhackInstruction;
          if IsDefined(instruction) && IsDefined(task.actor) {
            instruction.SetState(InstanceState.ON, this.DuplicateLastInstance(task.actor));
            instruction.SetContext(this.BaseOpenCheck());
          };
        };
      };
    } else {
      if this.m_calculateClose {
        if !IsDefined(this.m_hud.GetCurrentTarget()) || NotEquals(this.m_hud.GetCurrentTarget().GetType(), HUDActorType.DEVICE) || NotEquals(this.m_hud.GetCurrentTarget().GetType(), HUDActorType.BODY_DISPOSAL_DEVICE) || NotEquals(this.m_hud.GetCurrentTarget().GetType(), HUDActorType.PUPPET) {
          this.m_calculateClose = false;
          this.m_hud.GetLastTarget().SetShouldRefreshQHack(true);
          QuickhackModule.SendRevealQuickhackMenu(this.m_hud, this.m_hud.GetPlayer().GetEntityID(), false);
        };
      };
    };
  }

  protected func Process(out jobs: array<HUDJob>, mode: ActiveMode) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(jobs) {
      this.Process(jobs[i], mode);
      i += 1;
    };
  }

  public func Suppress(out jobs: array<HUDJob>) -> Void {
    let instruction: ref<QuickhackInstance>;
    let i: Int32 = 0;
    while i < ArraySize(jobs) {
      instruction = jobs[i].instruction.quickhackInstruction;
      instruction.SetState(InstanceState.DISABLED, this.DuplicateLastInstance(jobs[i].actor));
      i += 1;
    };
  }

  protected func DuplicateLastInstance(actor: ref<HUDActor>) -> ref<ModuleInstance> {
    return this.DuplicateLastInstance(actor);
  }

  protected final func BaseOpenCheck() -> Bool {
    if NotEquals(this.GetActiveMode(), ActiveMode.FOCUS) {
      return false;
    };
    if QuickhackModule.IsQuickhackBlockedByScene(this.m_hud.GetPlayer()) {
      return false;
    };
    if !this.m_hud.IsCyberdeckEquipped() {
      return false;
    };
    return true;
  }

  public final static func IsQuickhackBlockedByScene(player: ref<GameObject>) -> Bool {
    let tier: Int32 = (player as PlayerPuppet).GetPlayerStateMachineBlackboard().GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel);
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(player, n"NoQuickHacks") || tier >= EnumInt(gamePSMHighLevel.SceneTier3) && tier <= EnumInt(gamePSMHighLevel.SceneTier5) {
      return true;
    };
    return false;
  }

  public final static func RequestRefreshQuickhackMenu(context: GameInstance, requester: EntityID) -> Void {
    let self: ref<HUDManager> = GameInstance.GetScriptableSystemsContainer(context).Get(n"HUDManager") as HUDManager;
    if IsDefined(self) {
      if self.IsQuickHackPanelOpened() && self.GetCurrentTargetID() == requester {
        QuickhackModule.SendRevealQuickhackMenu(self, requester, true);
      };
    };
  }

  public final static func RequestCloseQuickhackMenu(context: GameInstance, requester: EntityID) -> Void {
    let self: ref<HUDManager> = GameInstance.GetScriptableSystemsContainer(context).Get(n"HUDManager") as HUDManager;
    if IsDefined(self) {
      QuickhackModule.SendRevealQuickhackMenu(self, requester, false);
    };
  }

  private final static func SendRevealQuickhackMenu(hudManager: ref<HUDManager>, requester: EntityID, shouldOpen: Bool) -> Void {
    let request: ref<RevealQuickhackMenu> = new RevealQuickhackMenu();
    request.shouldOpenWheel = shouldOpen;
    request.ownerID = requester;
    hudManager.QueueRequest(request);
  }

  public final static func TranslateEmptyQuickSlotCommands(context: GameInstance) -> array<ref<QuickhackData>> {
    let commands: array<ref<QuickhackData>>;
    let newCommand: ref<QuickhackData> = new QuickhackData();
    newCommand.m_title = "LocKey#42170";
    newCommand.m_isLocked = true;
    newCommand.m_description = "LocKey#42168";
    newCommand.m_inactiveReason = "LocKey#27694";
    newCommand.m_actionState = EActionInactivityReson.Invalid;
    ArrayPush(commands, newCommand);
    return commands;
  }

  private final func SendFakeCommands(commands: array<ref<QuickhackData>>, shouldReveal: Bool) -> Void {
    let playerRef: ref<PlayerPuppet> = this.GetPlayer() as PlayerPuppet;
    let quickSlotsManagerNotification: ref<RevealInteractionWheel> = new RevealInteractionWheel();
    quickSlotsManagerNotification.lookAtObject = null;
    quickSlotsManagerNotification.shouldReveal = shouldReveal;
    quickSlotsManagerNotification.commands = commands;
    this.m_hud.QueueEntityEvent(playerRef.GetEntityID(), quickSlotsManagerNotification);
  }

  public final static func CheckCommandDuplicates(out commands: array<ref<QuickhackData>>, opt characterRecord: wref<Character_Record>) -> Void {
    let actionRectord: wref<ObjectAction_Record>;
    let i1: Int32;
    let remove: Bool;
    let removeIndexes: array<Int32>;
    let i: Int32 = ArraySize(commands) - 1;
    while i >= 0 {
      remove = false;
      i1 = 0;
      while i1 < ArraySize(commands) {
        if i <= i1 {
        } else {
          if Equals(commands[i].m_title, commands[i1].m_title) {
            remove = true;
          } else {
            i1 += 1;
          };
        };
      };
      if remove {
        if IsDefined(characterRecord) {
          if IsDefined(commands[i].m_action) {
            if characterRecord.ObjectActionsContains(commands[i].m_action.GetObjectActionRecord()) {
              ArrayPush(removeIndexes, i1);
            } else {
              if IsDefined(commands[i1].m_action) {
                actionRectord = commands[i1].m_action.GetObjectActionRecord();
                if characterRecord.ObjectActionsContains(actionRectord) {
                  ArrayPush(removeIndexes, i);
                } else {
                  ArrayPush(removeIndexes, i);
                };
              } else {
                ArrayPush(removeIndexes, i);
              };
              if ArrayContains(removeIndexes, i) {
                ArrayPush(removeIndexes, i1);
              } else {
                if ArrayContains(removeIndexes, i1) {
                  ArrayPush(removeIndexes, i);
                } else {
                  if commands[i].m_actionMatchesTarget {
                    ArrayPush(removeIndexes, i1);
                  } else {
                    ArrayPush(removeIndexes, i);
                  };
                };
              };
            };
          } else {
            if IsDefined(commands[i1].m_action) {
              actionRectord = commands[i1].m_action.GetObjectActionRecord();
              if characterRecord.ObjectActionsContains(actionRectord) {
                ArrayPush(removeIndexes, i);
              } else {
                ArrayPush(removeIndexes, i);
              };
            } else {
              ArrayPush(removeIndexes, i);
            };
            if ArrayContains(removeIndexes, i) {
              ArrayPush(removeIndexes, i1);
            } else {
              if ArrayContains(removeIndexes, i1) {
                ArrayPush(removeIndexes, i);
              } else {
                if commands[i].m_actionMatchesTarget {
                  ArrayPush(removeIndexes, i1);
                } else {
                  ArrayPush(removeIndexes, i);
                };
              };
            };
          };
        } else {
          if ArrayContains(removeIndexes, i) {
            ArrayPush(removeIndexes, i1);
          } else {
            if ArrayContains(removeIndexes, i1) {
              ArrayPush(removeIndexes, i);
            } else {
              if commands[i].m_actionMatchesTarget {
                ArrayPush(removeIndexes, i1);
              } else {
                ArrayPush(removeIndexes, i);
              };
            };
          };
        };
      };
      i -= 1;
    };
    i = 0;
    while i < ArraySize(removeIndexes) {
      commands[removeIndexes[i]] = null;
      i += 1;
    };
    i = ArraySize(commands) - 1;
    while i >= 0 {
      if !IsDefined(commands[i]) {
        ArrayErase(commands, i);
      };
      i -= 1;
    };
  }

  public final static func SortCommandPriority(out commands: array<ref<QuickhackData>>, context: GameInstance) -> Void {
    let actionTDB: TweakDBID;
    let sortedArray: array<ref<QuickhackData>>;
    let activeIndex: Int32 = -1;
    let i: Int32 = ArraySize(commands) - 1;
    while i >= 0 {
      if !commands[i].m_isLocked || commands[i].m_actionMatchesTarget {
        actionTDB = commands[i].m_action.GetObjectActionID();
        if actionTDB == t"QuickHack.RemoteBreach" || actionTDB == t"DeviceAction.RemoteBreach" || actionTDB == t"QuickHack.ICEBreakerHack" {
          ArrayInsert(sortedArray, 0, commands[i]);
        } else {
          ArrayPush(sortedArray, commands[i]);
        };
        ArrayErase(commands, i);
        activeIndex += 1;
      };
      i -= 1;
    };
    if !NetworkSystem.ShouldShowOnlyTargetQuickHacks(context) {
      i = 0;
      while i < ArraySize(commands) {
        if commands[i].m_isLocked {
          ArrayPush(sortedArray, commands[i]);
        };
        i += 1;
      };
    };
    if ArraySize(sortedArray) == 0 {
      sortedArray = QuickhackModule.TranslateEmptyQuickSlotCommands(context);
      i = 0;
      while i < ArraySize(sortedArray) {
        sortedArray[i].m_inactiveReason = "LocKey#34276";
        sortedArray[i].m_title = "LocKey#42171";
        i += 1;
      };
    };
    commands = sortedArray;
  }
}

public class QuickhackInstance extends ModuleInstance {

  private let open: Bool;

  private let process: Bool;

  public final func ShouldOpen() -> Bool {
    return this.open;
  }

  public final func ShouldProcess() -> Bool {
    return this.process;
  }

  public final func SetContext(_open: Bool) -> Void {
    this.process = true;
    this.open = _open;
  }
}
