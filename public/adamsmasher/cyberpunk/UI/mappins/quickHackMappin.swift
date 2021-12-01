
public class QuickHackMappinController extends BaseInteractionMappinController {

  private edit let m_bar: inkWidgetRef;

  private edit let m_header: inkTextRef;

  private edit let m_iconWidgetActive: inkImageRef;

  private let m_rootWidget: wref<inkWidget>;

  private let m_mappin: wref<IMappin>;

  private let m_data: ref<GameplayRoleMappinData>;

  protected cb func OnInitialize() -> Bool {
    this.m_rootWidget = this.GetRootWidget();
  }

  protected cb func OnIntro() -> Bool {
    this.m_mappin = this.GetMappin();
    this.m_data = this.GetVisualData();
    this.HelperSetIcon(this.iconWidget, this.m_data.m_textureID);
    this.HelperSetIcon(this.m_iconWidgetActive, this.m_data.m_textureID);
    this.UpdateView();
  }

  protected cb func OnNameplate(isNameplateVisible: Bool, nameplateController: wref<NpcNameplateGameController>) -> Bool {
    if isNameplateVisible {
      this.SetProjectToScreenSpace(false);
    } else {
      this.SetProjectToScreenSpace(true);
    };
  }

  private final func OnStatsDataUpdated(progress: Float) -> Void {
    this.m_data = this.GetVisualData();
    if Equals(this.m_data.m_progressBarType, EProgressBarType.UPLOAD) {
      inkWidgetRef.SetScale(this.m_bar, new Vector2(2.00, progress));
    } else {
      if Equals(this.m_data.m_progressBarType, EProgressBarType.DURATION) {
        inkWidgetRef.SetScale(this.m_bar, new Vector2(2.00, 1.00 - progress));
      };
    };
    this.UpdateView();
  }

  private final func UpdateView() -> Void {
    if Equals(this.m_data.m_progressBarContext, EProgressBarContext.QuickHack) {
      if Equals(this.m_data.m_progressBarType, EProgressBarType.UPLOAD) {
        inkTextRef.SetText(this.m_header, "LocKey#11047");
        this.m_rootWidget.SetState(n"Upload");
      } else {
        if Equals(this.m_data.m_progressBarType, EProgressBarType.DURATION) {
          inkTextRef.SetText(this.m_header, "LocKey#11048");
          this.m_rootWidget.SetState(n"Default");
        };
      };
    } else {
      if Equals(this.m_data.m_progressBarContext, EProgressBarContext.PhoneCall) {
        inkTextRef.SetText(this.m_header, "LocKey#2142");
        this.m_rootWidget.SetState(n"Default");
      };
    };
  }

  public const func GetVisualData() -> ref<GameplayRoleMappinData> {
    let data: ref<GameplayRoleMappinData> = this.m_mappin.GetScriptData() as GameplayRoleMappinData;
    return data;
  }

  private final func HelperSetIcon(currImage: inkImageRef, iconID: TweakDBID) -> Void {
    if TDBID.IsValid(iconID) {
      this.SetTexture(currImage, iconID);
    };
  }
}
