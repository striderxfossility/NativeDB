
public class activityLogGameController extends inkHUDGameController {

  private let m_readIndex: Int32;

  private let m_writeIndex: Int32;

  private let m_maxSize: Int32;

  private let m_entries: array<String>;

  private edit let m_panel: inkVerticalPanelRef;

  private let m_onNewEntries: ref<CallbackHandle>;

  private let m_onHide: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    let bb: ref<IBlackboard>;
    let count: Int32;
    let entry: wref<activityLogEntryLogicController>;
    let i: Int32;
    let uiBlackboard: ref<IBlackboard>;
    this.m_readIndex = 0;
    this.m_writeIndex = 0;
    this.m_maxSize = 20;
    ArrayResize(this.m_entries, this.m_maxSize);
    if IsDefined(inkWidgetRef.Get(this.m_panel)) {
      count = inkCompoundRef.GetNumChildren(this.m_panel);
      i = 0;
      while i < count {
        entry = inkCompoundRef.GetWidget(this.m_panel, i).GetController() as activityLogEntryLogicController;
        if IsDefined(entry) {
          entry.Reset();
          entry.RegisterToCallback(n"OnTypingFinished", this, n"OnTypingFinished");
          entry.RegisterToCallback(n"OnDisappeared", this, n"OnDisappeared");
        };
        i += 1;
      };
    };
    uiBlackboard = this.GetUIBlackboard();
    if IsDefined(uiBlackboard) {
      this.m_onNewEntries = uiBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UIGameData.ActivityLog, this, n"OnNewEntries");
    };
    bb = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ActivityLog);
    if IsDefined(bb) {
      this.m_onHide = bb.RegisterListenerBool(GetAllBlackboardDefs().UI_ActivityLog.activityLogHide, this, n"OnHide");
    };
  }

  protected cb func OnUninitialize() -> Bool {
    let bb: ref<IBlackboard>;
    let uiBlackboard: ref<IBlackboard> = this.GetUIBlackboard();
    if IsDefined(uiBlackboard) {
      uiBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UIGameData.ActivityLog, this.m_onNewEntries);
    };
    bb = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_ActivityLog);
    if IsDefined(bb) {
      bb.UnregisterListenerBool(GetAllBlackboardDefs().UI_ActivityLog.activityLogHide, this.m_onHide);
    };
  }

  public final func AddNewEntry(value: String) -> Void {
    let entry: wref<activityLogEntryLogicController>;
    let widget: wref<inkWidget>;
    let count: Int32 = inkCompoundRef.GetNumChildren(this.m_panel);
    let bReset: Bool = true;
    let i: Int32 = 0;
    while i < count {
      widget = inkCompoundRef.GetWidget(this.m_panel, i);
      entry = widget.GetController() as activityLogEntryLogicController;
      if entry.IsAvailable() {
        entry.SetText(value);
        bReset = false;
      } else {
        i += 1;
      };
    };
    if bReset {
      widget = inkCompoundRef.GetWidget(this.m_panel, 0);
      entry = widget.GetController() as activityLogEntryLogicController;
      entry.Reset();
      entry.SetText(value);
      inkCompoundRef.ReorderChild(this.m_panel, widget, -1);
    };
  }

  protected cb func OnNewEntries(value: Variant) -> Bool {
    let newEntries: array<String> = FromVariant(value);
    let bAdd: Bool = this.m_readIndex == this.m_writeIndex;
    let count: Int32 = ArraySize(newEntries);
    let i: Int32 = 0;
    while i < count {
      if this.m_writeIndex - this.m_readIndex < this.m_maxSize {
        this.m_entries[this.m_writeIndex % this.m_maxSize] = newEntries[i];
        this.m_writeIndex += 1;
      } else {
        LogUIWarning("Too many pending entries in activity log!!! Ask UI team to increase stack size.");
        goto 381;
      };
      i += 1;
    };
    if bAdd && this.m_readIndex < this.m_writeIndex {
      this.AddNewEntry(this.m_entries[this.m_readIndex]);
    };
  }

  protected cb func OnTypingFinished(widget: wref<inkWidget>) -> Bool {
    this.m_entries[this.m_readIndex % this.m_maxSize] = "";
    this.m_readIndex += 1;
    if this.m_readIndex < this.m_writeIndex {
      this.AddNewEntry(this.m_entries[this.m_readIndex % this.m_maxSize]);
    } else {
      this.m_readIndex = 0;
      this.m_writeIndex = 0;
    };
  }

  protected cb func OnDisappeared(widget: wref<inkWidget>) -> Bool {
    let entry: wref<activityLogEntryLogicController> = widget.GetController() as activityLogEntryLogicController;
    entry.Reset();
    inkCompoundRef.ReorderChild(this.m_panel, widget, -1);
  }

  protected cb func OnHide(val: Bool) -> Bool {
    inkWidgetRef.SetVisible(this.m_panel, !val);
  }
}

public class activityLogEntryLogicController extends inkLogicController {

  private let m_available: Bool;

  private let m_originalSize: Uint16;

  private let m_size: Uint16;

  private let m_displayText: String;

  private let m_root: wref<inkText>;

  private let m_appearingAnim: ref<inkAnimController>;

  private let m_typingAnim: ref<inkAnimController>;

  private let m_disappearingAnim: ref<inkAnimController>;

  private let m_typingAnimDef: ref<inkAnimDef>;

  private let m_typingAnimProxy: ref<inkAnimProxy>;

  private let m_disappearingAnimDef: ref<inkAnimDef>;

  private let m_disappearingAnimProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    let size: Vector2;
    this.m_available = true;
    this.m_root = this.GetRootWidget() as inkText;
    this.m_root.SetLetterCase(textLetterCase.UpperCase);
    size = this.m_root.GetSize();
    this.m_appearingAnim = new inkAnimController();
    this.m_appearingAnim.Select(this.m_root).Interpolate(n"size", ToVariant(new Vector2(0.00, 0.00)), ToVariant(size)).Duration(0.20).Type(inkanimInterpolationType.Linear).Mode(inkanimInterpolationMode.EasyIn);
    this.m_typingAnim = new inkAnimController();
    this.m_typingAnim.Select(this.m_root).Interpolate(n"transparency", ToVariant(1.00), ToVariant(1.00)).Duration(0.00).Type(inkanimInterpolationType.Linear).Mode(inkanimInterpolationMode.EasyIn);
    this.m_disappearingAnim = new inkAnimController();
    this.m_disappearingAnim.Select(this.m_root).Interpolate(n"transparency", ToVariant(1.00), ToVariant(0.00)).Delay(1.00).Duration(0.50).Type(inkanimInterpolationType.Linear).Mode(inkanimInterpolationMode.EasyOut);
  }

  public final func SetText(displayText: String) -> Void {
    let typingAnimPlaybackOptions: inkAnimOptions;
    this.m_available = false;
    this.m_displayText = displayText;
    this.m_originalSize = Cast(StrLen(this.m_displayText));
    this.m_size = this.m_originalSize;
    this.m_root.SetText("");
    this.m_appearingAnim.Stop();
    this.m_appearingAnim.Play();
    typingAnimPlaybackOptions.loopType = inkanimLoopType.Cycle;
    typingAnimPlaybackOptions.loopCounter = Cast(this.m_originalSize + 1u);
    this.m_typingAnim.Stop();
    this.m_typingAnim.PlayWithOptions(typingAnimPlaybackOptions);
    this.m_typingAnim.RegisterToCallback(inkanimEventType.OnStartLoop, this, n"OnTyping");
    this.m_typingAnim.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnStopTyping");
    this.m_disappearingAnim.Stop();
  }

  public final func Reset() -> Void {
    this.m_appearingAnim.Stop();
    this.m_typingAnim.Stop();
    this.m_disappearingAnim.Stop();
    this.m_root.SetText("");
    this.m_root.SetSize(new Vector2(0.00, 0.00));
    this.m_available = true;
  }

  public final func IsAvailable() -> Bool {
    return this.m_available;
  }

  protected cb func OnTyping(proxy: ref<inkAnimProxy>) -> Bool {
    let nextSymbol: String = StrMid(this.m_displayText, Cast(this.m_originalSize - this.m_size), 1);
    this.m_root.SetLetterCase(textLetterCase.UpperCase);
    this.m_root.SetText(this.m_root.GetText() + nextSymbol);
    this.m_size -= 1u;
  }

  protected cb func OnStopTyping(proxy: ref<inkAnimProxy>) -> Bool {
    this.CallCustomCallback(n"OnTypingFinished");
    this.m_disappearingAnim.Play();
    this.m_disappearingAnim.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnDisappeared");
  }

  protected cb func OnDisappeared(proxy: ref<inkAnimProxy>) -> Bool {
    this.CallCustomCallback(n"OnDisappeared");
  }
}
