
public class MessangerReplyItemRenderer extends JournalEntryListItemController {

  private edit let m_textRoot: inkWidgetRef;

  private edit let m_background: inkWidgetRef;

  private let m_animSelectionBackground: ref<inkAnimProxy>;

  private let m_animSelectionText: ref<inkAnimProxy>;

  private let m_selectedState: Bool;

  @default(MessangerReplyItemRenderer, 0.3f)
  private let m_animationDuration: Float;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnSelected", this, n"OnSelected");
    this.RegisterToCallback(n"OnDeselected", this, n"OnDeselected");
    this.RegisterToCallback(n"OnButtonStateChanged", this, n"OnButtonStateChanged");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromCallback(n"OnSelected", this, n"OnSelected");
    this.UnregisterFromCallback(n"OnDeselected", this, n"OnDeselected");
    this.UnregisterFromCallback(n"OnButtonStateChanged", this, n"OnButtonStateChanged");
  }

  protected cb func OnButtonStateChanged(controller: wref<inkButtonController>, oldState: inkEButtonState, newState: inkEButtonState) -> Bool {
    if Equals(oldState, inkEButtonState.Normal) && Equals(newState, inkEButtonState.Hover) {
      this.SetSelected(true);
    } else {
      if Equals(oldState, inkEButtonState.Hover) && NotEquals(newState, inkEButtonState.Hover) {
        this.SetSelected(false);
      };
    };
  }

  protected cb func OnSelected(parent: wref<ListItemController>) -> Bool {
    if !this.m_selectedState {
      this.m_selectedState = !this.m_selectedState;
      this.AnimateSelection();
    };
  }

  protected cb func OnDeselected(parent: wref<ListItemController>) -> Bool {
    if this.m_selectedState {
      this.m_selectedState = !this.m_selectedState;
      this.AnimateSelection();
    };
  }

  protected func OnJournalEntryUpdated(entry: wref<JournalEntry>, extraData: ref<IScriptable>) -> Void {
    let choiceEntry: wref<JournalPhoneChoiceEntry> = entry as JournalPhoneChoiceEntry;
    inkTextRef.SetText(this.m_labelPathRef, choiceEntry.GetText());
    if choiceEntry.IsQuestImportant() {
      this.GetRootWidget().SetState(n"Quest");
    };
  }

  public final func AnimateSelection() -> Void {
    let adjustedTime: Float;
    let animBgEffectInterp: ref<inkAnimEffect>;
    let animEffectInterp: ref<inkAnimEffect>;
    let animSelect: ref<inkAnimDef>;
    let animSelectBg: ref<inkAnimDef>;
    let startValue: Float = inkWidgetRef.Get(this.m_textRoot).GetEffectParamValue(inkEffectType.LinearWipe, n"LinearWipe_0", n"transition");
    let endValue: Float = this.m_selectedState ? 1.00 : 0.00;
    if this.m_selectedState {
      inkWidgetRef.SetState(this.m_labelPathRef, n"Black");
    } else {
      inkWidgetRef.SetState(this.m_labelPathRef, n"Default");
    };
    adjustedTime = AbsF(endValue - startValue) * this.m_animationDuration;
    if IsDefined(this.m_animSelectionText) && this.m_animSelectionText.IsPlaying() {
      this.m_animSelectionText.Stop();
    };
    animSelect = new inkAnimDef();
    animEffectInterp = new inkAnimEffect();
    animEffectInterp.SetStartDelay(0.00);
    animEffectInterp.SetEffectType(inkEffectType.LinearWipe);
    animEffectInterp.SetEffectName(n"LinearWipe_0");
    animEffectInterp.SetParamName(n"transition");
    animEffectInterp.SetStartValue(startValue);
    animEffectInterp.SetEndValue(endValue);
    animEffectInterp.SetDuration(adjustedTime);
    animSelect.AddInterpolator(animEffectInterp);
    inkWidgetRef.Get(this.m_textRoot).SetEffectEnabled(inkEffectType.LinearWipe, n"LinearWipe_0", true);
    this.m_animSelectionText = inkWidgetRef.PlayAnimation(this.m_textRoot, animSelect);
    if IsDefined(this.m_animSelectionBackground) && this.m_animSelectionBackground.IsPlaying() {
      this.m_animSelectionBackground.Stop();
    };
    animSelectBg = new inkAnimDef();
    animBgEffectInterp = new inkAnimEffect();
    animBgEffectInterp.SetStartDelay(0.00);
    animBgEffectInterp.SetEffectType(inkEffectType.LinearWipe);
    animBgEffectInterp.SetEffectName(n"LinearWipe_0");
    animBgEffectInterp.SetParamName(n"transition");
    animBgEffectInterp.SetStartValue(startValue);
    animBgEffectInterp.SetEndValue(endValue);
    animBgEffectInterp.SetDuration(adjustedTime);
    animSelectBg.AddInterpolator(animBgEffectInterp);
    inkWidgetRef.Get(this.m_background).SetEffectEnabled(inkEffectType.LinearWipe, n"LinearWipe_0", true);
    this.m_animSelectionBackground = inkWidgetRef.PlayAnimation(this.m_background, animSelectBg);
  }
}

public class MessangerItemRenderer extends JournalEntryListItemController {

  private edit let m_image: inkImageRef;

  private edit let m_container: inkWidgetRef;

  private edit let m_fluffText: inkTextRef;

  @default(MessangerItemRenderer, Default)
  private let m_stateMessage: CName;

  @default(MessangerItemRenderer, Player)
  private let m_statePlayerReply: CName;

  private let m_imageId: TweakDBID;

  protected func OnJournalEntryUpdated(entry: wref<JournalEntry>, extraData: ref<IScriptable>) -> Void {
    let choiceEntry: wref<JournalPhoneChoiceEntry>;
    let contact: ref<ContactData>;
    let message: wref<JournalPhoneMessage>;
    let txt: String;
    let type: MessageViewType;
    inkWidgetRef.SetVisible(this.m_image, false);
    message = entry as JournalPhoneMessage;
    contact = extraData as ContactData;
    if IsDefined(message) {
      txt = message.GetText();
      type = Equals(message.GetSender(), gameMessageSender.NPC) ? MessageViewType.Received : MessageViewType.Sent;
      this.SetMessageView(txt, type, contact.localizedName);
      this.m_imageId = message.GetImageID();
      if TDBID.IsValid(this.m_imageId) {
        inkWidgetRef.SetVisible(this.m_image, true);
        InkImageUtils.RequestSetImage(this, this.m_image, this.m_imageId);
      } else {
        inkWidgetRef.SetVisible(this.m_image, false);
      };
    } else {
      choiceEntry = entry as JournalPhoneChoiceEntry;
      if IsDefined(choiceEntry) {
        txt = choiceEntry.GetText();
        this.SetMessageView(txt, MessageViewType.Sent, "");
        if choiceEntry.IsQuestImportant() {
          this.GetRootWidget().SetState(n"Quest");
        };
      } else {
        LogError("[MessangerItemRenderer] JournalEntry \'" + entry.GetEditorName() + "\' should have JournalPhoneMessage or JournalPhoneChoiceEntry type");
      };
    };
    inkTextRef.SetText(this.m_fluffText, "CHKSUM_" + IntToString(contact.hash));
  }

  private final func SetMessageView(txt: String, type: MessageViewType, contactName: String) -> Void {
    inkTextRef.SetText(this.m_labelPathRef, txt);
    if Equals(type, MessageViewType.Received) {
      this.GetRootWidget().SetState(this.m_stateMessage);
      inkWidgetRef.SetHAlign(this.m_container, inkEHorizontalAlign.Left);
    } else {
      this.GetRootWidget().SetState(this.m_statePlayerReply);
      inkWidgetRef.SetHAlign(this.m_container, inkEHorizontalAlign.Right);
    };
  }
}
