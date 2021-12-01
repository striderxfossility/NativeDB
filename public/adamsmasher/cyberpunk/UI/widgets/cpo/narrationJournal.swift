
public class NarrationJournalGameController extends inkHUDGameController {

  private edit let m_entriesContainer: inkCompoundRef;

  private let m_narrationJournalBlackboardId: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    let narrationJournalBB: ref<IBlackboard> = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_HUDNarrationLog);
    this.m_narrationJournalBlackboardId = narrationJournalBB.RegisterListenerVariant(GetAllBlackboardDefs().UI_HUDNarrationLog.LastEvent, this, n"OnEventAdded");
  }

  protected cb func OnEventAdded(value: Variant) -> Bool {
    let lastEvent: NarrationEvent = FromVariant(value);
    this.AddEntry(lastEvent);
  }

  private final func AddEntry(entry: NarrationEvent) -> Void {
    let entryPanel: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_entriesContainer), n"LogEntry");
    let controller: wref<LogEntryLogicController> = entryPanel.GetController() as LogEntryLogicController;
    controller.SetValues(entry);
    controller.RegisterToCallback(n"OnEntryHidden", this, n"OnEntryHidden");
  }

  protected cb func OnEntryHidden(entryWidget: wref<inkWidget>) -> Bool {
    inkCompoundRef.RemoveChild(this.m_entriesContainer, entryWidget);
  }
}

public class LogEntryLogicController extends inkLogicController {

  private let m_root: wref<inkWidget>;

  private edit let m_textWidget: inkTextRef;

  private let m_animProxyTimeout: ref<inkAnimProxy>;

  private let m_animProxyFadeOut: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget();
  }

  public final func SetValues(entry: NarrationEvent) -> Void {
    inkTextRef.SetText(this.m_textWidget, entry.text);
    inkWidgetRef.SetTintColor(this.m_textWidget, entry.color);
    this.SetTimeout(entry.durationSec);
  }

  private final func SetTimeout(value: Float) -> Void {
    let interpol: ref<inkAnimTransparency>;
    let timeoutAnim: ref<inkAnimDef>;
    if value > 0.00 {
      timeoutAnim = new inkAnimDef();
      interpol = new inkAnimTransparency();
      interpol.SetDuration(value);
      interpol.SetStartTransparency(1.00);
      interpol.SetEndTransparency(1.00);
      interpol.SetIsAdditive(true);
      timeoutAnim.AddInterpolator(interpol);
      this.m_animProxyTimeout = this.m_root.PlayAnimation(timeoutAnim);
      this.m_animProxyTimeout.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnTimeout");
    };
  }

  protected cb func OnTimeout(anim: ref<inkAnimProxy>) -> Bool {
    this.m_animProxyFadeOut = this.PlayLibraryAnimation(n"EntryFadeOut");
    this.m_animProxyFadeOut.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnHide");
  }

  protected cb func OnHide(anim: ref<inkAnimProxy>) -> Bool {
    this.m_root.SetVisible(false);
    this.CallCustomCallback(n"OnEntryHidden");
  }
}
