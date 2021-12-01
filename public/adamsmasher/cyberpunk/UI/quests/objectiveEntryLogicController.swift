
public class ObjectiveEntryLogicController extends inkLogicController {

  @default(ObjectiveEntryLogicController, 0.8f)
  public edit let m_blinkInterval: Float;

  @default(ObjectiveEntryLogicController, 5.0f)
  public edit let m_blinkTotalTime: Float;

  @default(ObjectiveEntryLogicController, tracked_left)
  public edit let m_texturePart_Tracked: CName;

  @default(ObjectiveEntryLogicController, untracked_left)
  public edit let m_texturePart_Untracked: CName;

  @default(ObjectiveEntryLogicController, succeeded)
  public edit let m_texturePart_Succeeded: CName;

  @default(ObjectiveEntryLogicController, failed)
  public edit let m_texturePart_Failed: CName;

  @default(ObjectiveEntryLogicController, false)
  public edit let m_isLargeUpdateWidget: Bool;

  private let m_entryName: wref<inkText>;

  private let m_entryOptional: wref<inkText>;

  private let m_stateIcon: wref<inkImage>;

  private let m_trackedIcon: wref<inkImage>;

  private let m_blinkWidget: wref<inkWidget>;

  private let m_root: wref<inkWidget>;

  private let m_animBlinkDef: ref<inkAnimDef>;

  private let m_animBlink: ref<inkAnimProxy>;

  private let m_animFadeDef: ref<inkAnimDef>;

  private let m_animFade: ref<inkAnimProxy>;

  private let m_entryId: Int32;

  private let m_type: UIObjectiveEntryType;

  private let m_state: gameJournalEntryState;

  private let m_parentEntry: wref<ObjectiveEntryLogicController>;

  @default(ObjectiveEntryLogicController, 0)
  private let m_childCount: Int32;

  private let m_updated: Bool;

  private let m_isTracked: Bool;

  public let m_isOptional: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget();
    this.m_blinkWidget = this.GetWidget(n"temp_blinker");
    this.m_stateIcon = this.GetWidget(n"temp_blinker/stateIcon") as inkImage;
    this.m_entryName = this.GetWidget(n"entryFlex/entryName") as inkText;
    this.m_entryOptional = this.GetWidget(n"entryOptional") as inkText;
    this.m_trackedIcon = this.GetWidget(n"tracked") as inkImage;
    this.CreateAnimations();
    this.m_blinkWidget.SetVisible(false);
    this.m_root.SetVisible(false);
  }

  public final func SetUpdated(updated: Bool) -> Void {
    this.m_updated = updated;
  }

  public final func IsUpdated() -> Bool {
    return this.m_updated;
  }

  public final func IsTracked() -> Bool {
    return this.m_isTracked;
  }

  public final func GetEntryType() -> UIObjectiveEntryType {
    return this.m_type;
  }

  public final func GetEntryState() -> gameJournalEntryState {
    return this.m_state;
  }

  public final func GetEntryId() -> Int32 {
    return this.m_entryId;
  }

  public final func SetEntryId(id: Int32) -> Void {
    this.m_entryId = id;
  }

  public final func SetEntryData(data: UIObjectiveEntryData) -> Void {
    let stateIconTexturePart: CName;
    let stateName: CName;
    this.m_root.SetVisible(false);
    this.SetUpdated(true);
    this.StopFadeAnimation();
    this.m_state = data.m_state;
    this.m_type = data.m_type;
    this.m_isTracked = data.m_isTracked;
    this.m_isOptional = data.m_isOptional;
    if Equals(this.m_state, gameJournalEntryState.Inactive) || Equals(data.m_name, "") {
      this.NotifyForRemoval();
      return;
    };
    LogUI("ObjectiveEntryLogicController:SetEntryData - Name: " + data.m_name);
    this.m_entryName.SetLetterCase(textLetterCase.UpperCase);
    if this.m_isOptional {
      this.m_entryName.SetText(Equals(this.m_type, UIObjectiveEntryType.Quest) ? data.m_name : GetLocalizedText(data.m_name) + data.m_counter + " [" + GetLocalizedText("UI-ScriptExports-Optional0") + "]");
    } else {
      this.m_entryName.SetText(Equals(this.m_type, UIObjectiveEntryType.Quest) ? data.m_name : GetLocalizedText(data.m_name) + data.m_counter);
    };
    stateIconTexturePart = this.GetStateIconTexturePart(this.m_state, data.m_isTracked);
    if Equals(stateIconTexturePart, n"") {
      this.m_stateIcon.SetVisible(false);
    } else {
      this.m_stateIcon.SetTexturePart(stateIconTexturePart);
    };
    stateName = QuestUIUtils.GetJournalStateName(this.m_state, this.m_isTracked);
    this.m_trackedIcon.SetVisible(this.m_isTracked);
    this.m_entryName.SetState(stateName);
    this.m_entryOptional.SetState(stateName);
    this.GetRootWidget().SetState(stateName);
    if Equals(this.m_state, gameJournalEntryState.Succeeded) || Equals(this.m_state, gameJournalEntryState.Failed) {
      if NotEquals(this.m_type, UIObjectiveEntryType.Quest) {
        if Equals(this.m_state, gameJournalEntryState.Succeeded) {
          this.m_animBlink = this.PlayLibraryAnimation(n"ObjectiveEntryComplete");
        };
        if Equals(this.m_state, gameJournalEntryState.Failed) {
          this.m_animBlink = this.PlayLibraryAnimation(n"ObjectiveEntryFailed");
        };
        this.m_animBlink.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationComplete");
      };
    } else {
      if Equals(this.m_state, gameJournalEntryState.Active) {
        this.Show();
      };
    };
  }

  private final func GetStateIconTexturePart(state: gameJournalEntryState, isTracked: Bool) -> CName {
    switch state {
      case gameJournalEntryState.Active:
        return isTracked ? this.m_texturePart_Tracked : this.m_texturePart_Untracked;
      case gameJournalEntryState.Succeeded:
        return this.m_texturePart_Succeeded;
      case gameJournalEntryState.Failed:
        return this.m_texturePart_Failed;
    };
    return n"";
  }

  private final func CreateAnimations() -> Void {
    let fadeInInterp: ref<inkAnimTransparency>;
    let fadeInterp: ref<inkAnimTransparency>;
    this.m_animBlinkDef = new inkAnimDef();
    let fadeOutInterp: ref<inkAnimTransparency> = new inkAnimTransparency();
    fadeOutInterp.SetStartTransparency(0.20);
    fadeOutInterp.SetEndTransparency(3.00);
    fadeOutInterp.SetDuration(this.m_blinkInterval / 2.00);
    fadeOutInterp.SetType(inkanimInterpolationType.Linear);
    this.m_animBlinkDef.AddInterpolator(fadeOutInterp);
    fadeInInterp = new inkAnimTransparency();
    fadeInInterp.SetStartTransparency(0.20);
    fadeInInterp.SetEndTransparency(3.00);
    fadeInInterp.SetDuration(this.m_blinkInterval / 2.00);
    fadeInInterp.SetType(inkanimInterpolationType.Linear);
    this.m_animBlinkDef.AddInterpolator(fadeInInterp);
    this.m_animFadeDef = new inkAnimDef();
    fadeInterp = new inkAnimTransparency();
    fadeInterp.SetStartTransparency(1.00);
    fadeInterp.SetEndTransparency(1.00);
    fadeInterp.SetDuration(0.00);
    fadeInterp.SetDirection(inkanimInterpolationDirection.To);
    fadeInterp.SetType(inkanimInterpolationType.Linear);
    this.m_animFadeDef.AddInterpolator(fadeInterp);
  }

  public final func IsReadyToRemove() -> Bool {
    return !Equals(this.m_state, gameJournalEntryState.Active);
  }

  protected cb func OnAnimationComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.m_root.SetVisible(false);
    this.NotifyForRemoval();
  }

  private final func NotifyForRemoval() -> Void {
    this.CallCustomCallback(n"OnReadyToRemove");
  }

  public final func Hide() -> Void {
    if Equals(this.m_type, UIObjectiveEntryType.Quest) {
      this.m_root.SetVisible(false);
      this.NotifyForRemoval();
      return;
    };
    if Equals(this.m_state, gameJournalEntryState.Succeeded) || Equals(this.m_state, gameJournalEntryState.Failed) {
      return;
    };
    if this.m_animBlink.IsPlaying() {
      this.m_animBlink.Stop();
    };
    this.m_animBlink = this.PlayLibraryAnimation(n"ObjectiveEntryFadeOut");
    this.m_animBlink.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationComplete");
  }

  private final func StopFadeAnimation() -> Void {
    if IsDefined(this.m_animBlink) && this.m_animBlink.IsPlaying() {
      this.m_animBlink.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnAnimationComplete");
      this.m_animBlink.Stop();
    };
    if IsDefined(this.m_animFade) && this.m_animFade.IsPlaying() {
      this.m_animFade.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnAnimationComplete");
      this.m_animFade.Stop();
    };
    this.m_root.SetOpacity(1.00);
  }

  public final func Show() -> Void {
    this.m_root.SetVisible(true);
  }

  public final func AttachToParent(parentEntry: wref<ObjectiveEntryLogicController>) -> Void {
    this.m_parentEntry = parentEntry;
    this.m_parentEntry.IncrementChildCount();
  }

  public final func DetachFromParent() -> Void {
    this.m_parentEntry.DecrementChildCount();
    this.m_parentEntry = null;
  }

  public final func IncrementChildCount() -> Void {
    this.m_childCount += 1;
  }

  public final func DecrementChildCount() -> Void {
    this.m_childCount -= 1;
  }
}
