
public class hudCorpoController extends inkHUDGameController {

  private edit let m_ScrollText: inkTextRef;

  private edit let m_ScrollTextWidget: inkWidgetRef;

  private edit let m_root_canvas: inkWidgetRef;

  private let m_root: wref<inkCompoundWidget>;

  private let m_fact1ListenerId: Uint32;

  private let m_fact2ListenerId: Uint32;

  private let m_fact3ListenerId: Uint32;

  private let m_fact4ListenerId: Uint32;

  private let m_fact5ListenerId: Uint32;

  protected cb func OnInitialize() -> Bool {
    let ownerObject: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    this.m_fact1ListenerId = GameInstance.GetQuestsSystem(ownerObject.GetGame()).RegisterListener(n"q000_corpo_scrollbar_mirror", this, n"OnQ000_corpo_scrollbar_mirror");
    this.OnQ000_corpo_scrollbar_mirror(GameInstance.GetQuestsSystem(ownerObject.GetGame()).GetFact(n"q000_corpo_scrollbar_mirror"));
    this.m_fact2ListenerId = GameInstance.GetQuestsSystem(ownerObject.GetGame()).RegisterListener(n"q000_corpo_scrollbar_office", this, n"OnQ000_corpo_scrollbar_office");
    this.OnQ000_corpo_scrollbar_office(GameInstance.GetQuestsSystem(ownerObject.GetGame()).GetFact(n"q000_corpo_scrollbar_office"));
    this.m_fact3ListenerId = GameInstance.GetQuestsSystem(ownerObject.GetGame()).RegisterListener(n"q000_corpo_scrollbar_after_meeting", this, n"OnQ000_corpo_scrollbar_after_meeting");
    this.OnQ000_corpo_scrollbar_after_meeting(GameInstance.GetQuestsSystem(ownerObject.GetGame()).GetFact(n"q000_corpo_scrollbar_after_meeting"));
    this.m_fact4ListenerId = GameInstance.GetQuestsSystem(ownerObject.GetGame()).RegisterListener(n"q000_corpo_scrollbar_disconnect", this, n"OnQ000_corpo_scrollbar_disconnect");
    this.OnQ000_corpo_scrollbar_disconnect(GameInstance.GetQuestsSystem(ownerObject.GetGame()).GetFact(n"q000_corpo_scrollbar_disconnect"));
    this.m_fact5ListenerId = GameInstance.GetQuestsSystem(ownerObject.GetGame()).RegisterListener(n"q000_var_arasaka_ui_on", this, n"OnQ000_var_arasaka_ui_on");
    this.OnQ000_var_arasaka_ui_on(GameInstance.GetQuestsSystem(ownerObject.GetGame()).GetFact(n"q000_var_arasaka_ui_on"));
    this.m_root = this.GetRootWidget() as inkCompoundWidget;
    inkWidgetRef.SetVisible(this.m_ScrollTextWidget, false);
  }

  protected cb func OnUninitialize() -> Bool {
    let ownerObject: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    GameInstance.GetQuestsSystem(ownerObject.GetGame()).UnregisterListener(n"q000_corpo_scrollbar_mirror", this.m_fact1ListenerId);
    GameInstance.GetQuestsSystem(ownerObject.GetGame()).UnregisterListener(n"q000_corpo_scrollbar_office", this.m_fact2ListenerId);
    GameInstance.GetQuestsSystem(ownerObject.GetGame()).UnregisterListener(n"q000_corpo_scrollbar_after_meeting", this.m_fact3ListenerId);
    GameInstance.GetQuestsSystem(ownerObject.GetGame()).UnregisterListener(n"q000_corpo_scrollbar_disconnect", this.m_fact4ListenerId);
    GameInstance.GetQuestsSystem(ownerObject.GetGame()).UnregisterListener(n"q000_var_arasaka_ui_on", this.m_fact5ListenerId);
  }

  public final func OnQ000_corpo_scrollbar_mirror(val: Int32) -> Void {
    inkWidgetRef.SetVisible(this.m_ScrollTextWidget, false);
    if val > 0 {
      inkWidgetRef.SetVisible(this.m_ScrollTextWidget, true);
      inkTextRef.SetText(this.m_ScrollText, "LocKey#46993");
    };
  }

  public final func OnQ000_corpo_scrollbar_office(val: Int32) -> Void {
    inkWidgetRef.SetVisible(this.m_ScrollTextWidget, false);
    if val > 0 {
      inkWidgetRef.SetVisible(this.m_ScrollTextWidget, true);
      inkTextRef.SetText(this.m_ScrollText, "LocKey#46994");
    };
  }

  public final func OnQ000_corpo_scrollbar_after_meeting(val: Int32) -> Void {
    inkWidgetRef.SetVisible(this.m_ScrollTextWidget, false);
    if val > 0 {
      inkWidgetRef.SetVisible(this.m_ScrollTextWidget, true);
      inkTextRef.SetText(this.m_ScrollText, "LocKey#47000");
    };
  }

  public final func OnQ000_corpo_scrollbar_disconnect(val: Int32) -> Void {
    inkWidgetRef.SetVisible(this.m_ScrollTextWidget, false);
    if val > 0 {
      inkWidgetRef.SetVisible(this.m_ScrollTextWidget, true);
      inkTextRef.SetText(this.m_ScrollText, "LocKey#47003");
    };
  }

  public final func OnQ000_var_arasaka_ui_on(val: Int32) -> Void {
    if val > 0 {
      this.m_root.SetVisible(true);
      inkWidgetRef.SetVisible(this.m_root_canvas, true);
    } else {
      if IsDefined(this.m_root) {
        this.m_root.SetVisible(false);
      };
      inkWidgetRef.SetVisible(this.m_root_canvas, false);
    };
  }
}
