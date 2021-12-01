
public class BriefingScreen extends inkHUDGameController {

  public edit let m_logicControllerRef: inkWidgetRef;

  protected let m_journalManager: wref<JournalManager>;

  private let m_bbOpenerEventID: ref<CallbackHandle>;

  private let m_bbSizeEventID: ref<CallbackHandle>;

  private let m_bbAlignmentEventID: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    this.m_journalManager = GameInstance.GetJournalManager(this.GetPlayerControlledObject().GetGame());
    this.m_bbOpenerEventID = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Briefing).RegisterDelayedListenerString(GetAllBlackboardDefs().UI_Briefing.BriefingToOpen, this, n"OnBriefingOpenerCalled");
    this.m_bbSizeEventID = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Briefing).RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_Briefing.BriefingSize, this, n"OnBriefingSizeCalled");
    this.m_bbAlignmentEventID = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Briefing).RegisterDelayedListenerVariant(GetAllBlackboardDefs().UI_Briefing.BriefingAlignment, this, n"OnBriefingAlignmentCalled");
  }

  protected cb func OnBriefingOpenerCalled(value: String) -> Bool {
    let childEntries: array<wref<JournalEntry>>;
    let context: JournalRequestContext;
    let entries: array<wref<JournalEntry>>;
    let logicController: ref<BriefingScreenLogic>;
    let parent: String;
    let parentEntry: wref<JournalEntry>;
    let target: String;
    let targetEntry: wref<JournalEntry>;
    StrSplitLast(StrLower(value), "/", parent, target);
    context.stateFilter.active = true;
    this.m_journalManager.GetBriefings(context, entries);
    parentEntry = this.FindEntry(parent, entries);
    this.m_journalManager.GetChildren(parentEntry, context.stateFilter, childEntries);
    targetEntry = this.FindEntry(target, childEntries);
    logicController = inkWidgetRef.GetController(this.m_logicControllerRef) as BriefingScreenLogic;
    logicController.ShowBriefing(targetEntry);
  }

  protected cb func OnBriefingSizeCalled(value: Variant) -> Bool {
    let logicController: ref<BriefingScreenLogic> = inkWidgetRef.GetController(this.m_logicControllerRef) as BriefingScreenLogic;
    logicController.SetSize(FromVariant(value));
  }

  protected cb func OnBriefingAlignmentCalled(value: Variant) -> Bool {
    let logicController: ref<BriefingScreenLogic> = inkWidgetRef.GetController(this.m_logicControllerRef) as BriefingScreenLogic;
    logicController.SetAlignment(FromVariant(value));
  }

  private final func FindEntry(toFind: String, entries: array<wref<JournalEntry>>) -> ref<JournalEntry> {
    let i: Int32 = 0;
    while i < ArraySize(entries) {
      if Equals(entries[i].GetId(), toFind) {
        return entries[i];
      };
      i += 1;
    };
    return null;
  }

  protected cb func OnUninitialize() -> Bool {
    this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Briefing).UnregisterDelayedListener(GetAllBlackboardDefs().UI_Briefing.BriefingToOpen, this.m_bbOpenerEventID);
    this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Briefing).UnregisterDelayedListener(GetAllBlackboardDefs().UI_Briefing.BriefingSize, this.m_bbSizeEventID);
    this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Briefing).UnregisterDelayedListener(GetAllBlackboardDefs().UI_Briefing.BriefingAlignment, this.m_bbAlignmentEventID);
  }
}

public class BriefingScreenLogic extends inkLogicController {

  protected let m_lastSizeSet: Vector2;

  protected let m_isBriefingVisible: Bool;

  protected let m_briefingToOpen: wref<JournalEntry>;

  private edit let m_videoWidget: inkVideoRef;

  private edit let m_mapWidget: inkWidgetRef;

  private edit let m_paperdollWidget: inkWidgetRef;

  private edit let m_animatedWidget: inkWidgetRef;

  private edit let m_fadeDuration: Float;

  private edit let m_InterpolationType: inkanimInterpolationType;

  private edit let m_InterpolationMode: inkanimInterpolationMode;

  private edit let m_minimizedSize: Vector2;

  private edit let m_maximizedSize: Vector2;

  protected cb func OnInitialize() -> Bool {
    this.HideAll();
    this.m_lastSizeSet = this.m_minimizedSize;
    this.m_isBriefingVisible = false;
  }

  public final func ShowBriefing(briefingToOpen: wref<JournalEntry>) -> Void {
    this.m_briefingToOpen = briefingToOpen;
    if this.m_isBriefingVisible {
      this.Fade(1.00, 0.00, n"OnFadeOutEnd");
    } else {
      this.SetBriefing();
    };
  }

  private final func SetBriefing() -> Void {
    let toOpen: ref<JournalBriefingBaseSection>;
    this.HideAll();
    if IsDefined(this.m_briefingToOpen) {
      toOpen = this.m_briefingToOpen as JournalBriefingBaseSection;
      switch toOpen.GetType() {
        case gameJournalBriefingContentType.MapLocation:
          this.ProcessMap(this.m_briefingToOpen as JournalBriefingMapSection);
          break;
        case gameJournalBriefingContentType.VideoContent:
          this.ProcessVideo(this.m_briefingToOpen as JournalBriefingVideoSection);
          break;
        case gameJournalBriefingContentType.Paperdoll:
          this.ProcessPaperdoll(this.m_briefingToOpen as JournalBriefingPaperDollSection);
      };
      this.Fade(0.00, 1.00, n"OnFadeInEnd");
      this.m_briefingToOpen = null;
    };
  }

  protected cb func OnFadeInEnd(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_isBriefingVisible = true;
  }

  protected cb func OnFadeOutEnd(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_isBriefingVisible = false;
    this.SetBriefing();
  }

  private final func ProcessMap(toProcess: ref<JournalBriefingMapSection>) -> Void {
    this.GetRootWidget().SetVisible(true);
    inkWidgetRef.SetVisible(this.m_mapWidget, true);
  }

  private final func ProcessVideo(toProcess: ref<JournalBriefingVideoSection>) -> Void {
    this.GetRootWidget().SetVisible(true);
    inkWidgetRef.SetVisible(this.m_videoWidget, true);
    inkVideoRef.SetVideoPath(this.m_videoWidget, toProcess.GetVideoPath());
    inkVideoRef.Play(this.m_videoWidget);
  }

  private final func ProcessPaperdoll(toProcess: ref<JournalBriefingPaperDollSection>) -> Void {
    this.GetRootWidget().SetVisible(true);
    inkWidgetRef.SetVisible(this.m_paperdollWidget, true);
  }

  private final func Fade(startValue: Float, endValue: Float, callbackName: CName) -> Void {
    let animProxy: ref<inkAnimProxy>;
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetDuration(this.m_fadeDuration);
    alphaInterpolator.SetStartTransparency(startValue);
    alphaInterpolator.SetEndTransparency(endValue);
    alphaInterpolator.SetMode(this.m_InterpolationMode);
    alphaInterpolator.SetType(this.m_InterpolationType);
    anim.AddInterpolator(alphaInterpolator);
    animProxy = inkWidgetRef.PlayAnimation(this.m_animatedWidget, anim);
    animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, callbackName);
  }

  public final func SetSize(sizeToSet: questJournalSizeEventType) -> Void {
    let targetSize: Vector2;
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let sizeInterpolator: ref<inkAnimSize> = new inkAnimSize();
    switch sizeToSet {
      case questJournalSizeEventType.Maximize:
        targetSize = this.m_maximizedSize;
        break;
      case questJournalSizeEventType.Minimize:
        targetSize = this.m_minimizedSize;
    };
    sizeInterpolator.SetStartSize(this.m_lastSizeSet);
    sizeInterpolator.SetEndSize(targetSize);
    sizeInterpolator.SetDuration(this.m_fadeDuration);
    sizeInterpolator.SetMode(this.m_InterpolationMode);
    sizeInterpolator.SetType(this.m_InterpolationType);
    anim.AddInterpolator(sizeInterpolator);
    inkWidgetRef.PlayAnimation(this.m_animatedWidget, anim);
    this.m_lastSizeSet = targetSize;
  }

  public final func SetAlignment(alignmentToSet: questJournalAlignmentEventType) -> Void {
    let targetAnchor: inkEAnchor;
    let xAnchorPoint: Float;
    switch alignmentToSet {
      case questJournalAlignmentEventType.Left:
        targetAnchor = inkEAnchor.TopLeft;
        xAnchorPoint = 0.00;
        break;
      case questJournalAlignmentEventType.Center:
        targetAnchor = inkEAnchor.TopCenter;
        xAnchorPoint = 0.50;
        break;
      case questJournalAlignmentEventType.Right:
        targetAnchor = inkEAnchor.TopRight;
        xAnchorPoint = 1.00;
    };
    inkWidgetRef.SetAnchor(this.m_animatedWidget, targetAnchor);
    inkWidgetRef.SetAnchorPoint(this.m_animatedWidget, xAnchorPoint, 0.00);
  }

  private final func HideAll() -> Void {
    this.GetRootWidget().SetVisible(false);
    inkWidgetRef.SetVisible(this.m_videoWidget, false);
    inkWidgetRef.SetVisible(this.m_mapWidget, false);
    inkWidgetRef.SetVisible(this.m_paperdollWidget, false);
  }
}
