
public class hudButtonReminderGameController extends inkHUDGameController {

  private edit let m_Button1: inkCompoundRef;

  private edit let m_Button2: inkCompoundRef;

  private edit let m_Button3: inkCompoundRef;

  private let m_uiHudButtonHelpBB: wref<IBlackboard>;

  private let m_interactingWithDeviceBBID: ref<CallbackHandle>;

  private let m_OnRedrawText_1Callback: ref<CallbackHandle>;

  private let m_OnRedrawIcon_1Callback: ref<CallbackHandle>;

  private let m_OnRedrawText_2Callback: ref<CallbackHandle>;

  private let m_OnRedrawIcon_2Callback: ref<CallbackHandle>;

  private let m_OnRedrawText_3Callback: ref<CallbackHandle>;

  private let m_OnRedrawIcon_3Callback: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    this.m_uiHudButtonHelpBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_HudButtonHelp);
    if IsDefined(this.m_uiHudButtonHelpBB) {
      this.m_OnRedrawText_1Callback = this.m_uiHudButtonHelpBB.RegisterListenerString(GetAllBlackboardDefs().UI_HudButtonHelp.button1_Text, this, n"OnRedrawText_1");
      this.m_OnRedrawIcon_1Callback = this.m_uiHudButtonHelpBB.RegisterListenerName(GetAllBlackboardDefs().UI_HudButtonHelp.button1_Icon, this, n"OnRedrawIcon_1");
      this.m_OnRedrawText_2Callback = this.m_uiHudButtonHelpBB.RegisterListenerString(GetAllBlackboardDefs().UI_HudButtonHelp.button2_Text, this, n"OnRedrawText_2");
      this.m_OnRedrawIcon_2Callback = this.m_uiHudButtonHelpBB.RegisterListenerName(GetAllBlackboardDefs().UI_HudButtonHelp.button2_Icon, this, n"OnRedrawIcon_2");
      this.m_OnRedrawText_3Callback = this.m_uiHudButtonHelpBB.RegisterListenerString(GetAllBlackboardDefs().UI_HudButtonHelp.button3_Text, this, n"OnRedrawText_3");
      this.m_OnRedrawIcon_3Callback = this.m_uiHudButtonHelpBB.RegisterListenerName(GetAllBlackboardDefs().UI_HudButtonHelp.button3_Icon, this, n"OnRedrawIcon_3");
    };
    inkWidgetRef.SetVisible(this.m_Button1, false);
    inkWidgetRef.SetVisible(this.m_Button2, false);
    inkWidgetRef.SetVisible(this.m_Button3, false);
  }

  protected cb func OnPlayerAttach(playerGameObject: ref<GameObject>) -> Bool {
    this.RegisterPSMListeners(playerGameObject);
  }

  protected cb func OnPlayerDetach(playerGameObject: ref<GameObject>) -> Bool {
    this.UnregisterPSMListeners(playerGameObject);
  }

  protected final func RegisterPSMListeners(playerPuppet: ref<GameObject>) -> Void {
    let playerStateMachineBB: ref<IBlackboard> = this.GetPSMBlackboard(playerPuppet);
    if IsDefined(playerStateMachineBB) {
      this.m_interactingWithDeviceBBID = playerStateMachineBB.RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, this, n"OnInteractingWithDevice");
    };
  }

  protected final func UnregisterPSMListeners(playerPuppet: ref<GameObject>) -> Void {
    let playerStateMachineBB: ref<IBlackboard> = this.GetPSMBlackboard(playerPuppet);
    if IsDefined(playerStateMachineBB) {
      playerStateMachineBB.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, this.m_interactingWithDeviceBBID);
    };
  }

  private final func OnRedrawText_1(argValue: String) -> Void {
    (inkCompoundRef.GetWidget(this.m_Button1, n"buttonText") as inkText).SetText(argValue);
    inkWidgetRef.SetVisible(this.m_Button1, Cast(StrLen(argValue)));
  }

  private final func OnRedrawIcon_1(argValue: CName) -> Void {
    (inkCompoundRef.GetWidget(this.m_Button1, n"buttonIcon") as inkImage).SetTexturePart(argValue);
  }

  private final func OnRedrawText_2(argValue: String) -> Void {
    (inkCompoundRef.GetWidget(this.m_Button2, n"buttonText") as inkText).SetText(argValue);
    inkWidgetRef.SetVisible(this.m_Button2, Cast(StrLen(argValue)));
  }

  private final func OnRedrawIcon_2(argValue: CName) -> Void {
    (inkCompoundRef.GetWidget(this.m_Button2, n"buttonIcon") as inkImage).SetTexturePart(argValue);
  }

  private final func OnRedrawText_3(argValue: String) -> Void {
    (inkCompoundRef.GetWidget(this.m_Button3, n"buttonText") as inkText).SetText(argValue);
    inkWidgetRef.SetVisible(this.m_Button3, Cast(StrLen(argValue)));
  }

  private final func OnRedrawIcon_3(argValue: CName) -> Void {
    (inkCompoundRef.GetWidget(this.m_Button3, n"buttonIcon") as inkImage).SetTexturePart(argValue);
  }

  protected cb func OnInteractingWithDevice(value: Bool) -> Bool {
    (inkCompoundRef.GetWidget(this.m_Button1, n"buttonText") as inkText).SetText("UI-Cyberpunk-Interactions-Leave");
    (inkCompoundRef.GetWidget(this.m_Button1, n"buttonIcon") as inkImage).SetTexturePart(n"b");
    inkWidgetRef.SetVisible(this.m_Button1, value);
  }
}
