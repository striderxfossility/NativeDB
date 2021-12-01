
public class MetaQuestLogicController extends inkLogicController {

  private edit let m_MetaQuestHint: inkWidgetRef;

  private edit let m_MetaQuestHintText: inkTextRef;

  private edit let m_MetaQuest1: inkWidgetRef;

  private edit let m_MetaQuest2: inkWidgetRef;

  private edit let m_MetaQuest3: inkWidgetRef;

  private edit let m_MetaQuest1Value: inkTextRef;

  private edit let m_MetaQuest2Value: inkTextRef;

  private edit let m_MetaQuest3Value: inkTextRef;

  private let m_metaQuest1Description: String;

  private let m_metaQuest2Description: String;

  private let m_metaQuest3Description: String;

  private let animMeta1: ref<inkAnimProxy>;

  private let animMeta2: ref<inkAnimProxy>;

  private let animMeta3: ref<inkAnimProxy>;

  private let animTooltip: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.InitMetaQuestControlls();
  }

  private final func InitMetaQuestControlls() -> Void {
    inkWidgetRef.RegisterToCallback(this.m_MetaQuest1, n"OnHoverOver", this, n"OnItem1HoverOver");
    inkWidgetRef.RegisterToCallback(this.m_MetaQuest2, n"OnHoverOver", this, n"OnItem2HoverOver");
    inkWidgetRef.RegisterToCallback(this.m_MetaQuest3, n"OnHoverOver", this, n"OnItem3HoverOver");
    inkWidgetRef.RegisterToCallback(this.m_MetaQuest1, n"OnHoverOut", this, n"OnHoverOut");
    inkWidgetRef.RegisterToCallback(this.m_MetaQuest2, n"OnHoverOut", this, n"OnHoverOut");
    inkWidgetRef.RegisterToCallback(this.m_MetaQuest3, n"OnHoverOut", this, n"OnHoverOut");
  }

  public final func SetMetaQuests(status: MetaQuestStatus) -> Void {
    if NotEquals(status.MetaQuest1Description, "") {
      this.m_metaQuest1Description = status.MetaQuest1Description;
    } else {
      this.m_metaQuest1Description = "[Error: No description defined by the quest block. Contact quest team.]";
    };
    if NotEquals(status.MetaQuest2Description, "") {
      this.m_metaQuest2Description = status.MetaQuest2Description;
    } else {
      this.m_metaQuest2Description = "[Error: No description defined by the quest block. Contact quest team.]";
    };
    if NotEquals(status.MetaQuest3Description, "") {
      this.m_metaQuest3Description = status.MetaQuest3Description;
    } else {
      this.m_metaQuest3Description = "[Error: No description defined by the quest block. Contact quest team.]";
    };
    inkTextRef.SetText(this.m_MetaQuest1Value, status.MetaQuest1Value + "%");
    inkTextRef.SetText(this.m_MetaQuest2Value, status.MetaQuest2Value + "%");
    inkTextRef.SetText(this.m_MetaQuest3Value, status.MetaQuest3Value + "%");
    inkWidgetRef.SetVisible(this.m_MetaQuest1, !status.MetaQuest1Hidden);
    inkWidgetRef.SetVisible(this.m_MetaQuest2, !status.MetaQuest2Hidden);
    inkWidgetRef.SetVisible(this.m_MetaQuest3, !status.MetaQuest3Hidden);
  }

  protected cb func OnItem1HoverOver(evt: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_MetaQuestHint, true);
    inkTextRef.SetText(this.m_MetaQuestHintText, GetLocalizedText(this.m_metaQuest1Description));
    inkWidgetRef.SetMargin(this.m_MetaQuestHint, new inkMargin(-400.00, 0.00, 0.00, 0.00));
    this.animTooltip.Stop();
    if !this.animMeta1.IsPlaying() {
      this.animMeta1 = this.PlayLibraryAnimation(n"metaquest1_hoverin");
    };
    this.animTooltip = this.PlayLibraryAnimation(n"tooltip_in");
  }

  protected cb func OnItem2HoverOver(evt: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_MetaQuestHint, true);
    inkTextRef.SetText(this.m_MetaQuestHintText, GetLocalizedText(this.m_metaQuest2Description));
    inkWidgetRef.SetMargin(this.m_MetaQuestHint, new inkMargin(50.00, 0.00, 0.00, 0.00));
    this.animTooltip.Stop();
    if !this.animMeta2.IsPlaying() {
      this.animMeta2 = this.PlayLibraryAnimation(n"metaquest2_hoverin");
    };
    this.animTooltip = this.PlayLibraryAnimation(n"tooltip_in");
  }

  protected cb func OnItem3HoverOver(evt: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_MetaQuestHint, true);
    inkTextRef.SetText(this.m_MetaQuestHintText, GetLocalizedText(this.m_metaQuest3Description));
    inkWidgetRef.SetMargin(this.m_MetaQuestHint, new inkMargin(500.00, 0.00, 0.00, 0.00));
    this.animTooltip.Stop();
    if !this.animMeta3.IsPlaying() {
      this.animMeta3 = this.PlayLibraryAnimation(n"metaquest3_hoverin");
    };
    this.animTooltip = this.PlayLibraryAnimation(n"tooltip_in");
  }

  protected cb func OnHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_MetaQuestHint, false);
  }
}
