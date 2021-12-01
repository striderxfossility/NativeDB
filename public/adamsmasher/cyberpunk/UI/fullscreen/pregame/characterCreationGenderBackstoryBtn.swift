
public class characterCreationGenderBackstoryBtn extends inkButtonController {

  public edit let m_selector: inkWidgetRef;

  public edit let m_fluffText: inkWidgetRef;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.SetVisible(this.m_selector, false);
    inkWidgetRef.SetVisible(this.m_fluffText, true);
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
  }

  public final func Refresh(newName: String, gender: Bool) -> Void;

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_selector, true);
    inkWidgetRef.SetVisible(this.m_fluffText, false);
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_fluffText, true);
  }
}

public class characterCreationLifePathBtn extends inkButtonController {

  public edit let m_selector: inkWidgetRef;

  public edit let m_desc: inkTextRef;

  public edit let m_image: inkImageRef;

  public edit let m_label: inkTextRef;

  public edit let m_video: inkVideoRef;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_root: wref<inkWidget>;

  private let translationAnimationCtrl: wref<inkTextReplaceController>;

  private let localizedText: String;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.SetVisible(this.m_selector, false);
    inkWidgetRef.SetVisible(this.m_desc, false);
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    this.m_root = this.GetRootWidget();
    inkVideoRef.Stop(this.m_video);
  }

  public final func SetDescription(desc: CName, imagePath: CName, videoPath: ResRef, label: CName) -> Void {
    this.localizedText = GetLocalizedText(NameToString(desc));
    inkImageRef.SetTexturePart(this.m_image, imagePath);
    inkTextRef.SetText(this.m_label, GetLocalizedText(NameToString(label)));
    inkVideoRef.SetVideoPath(this.m_video, videoPath);
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_selector, true);
    inkWidgetRef.SetVisible(this.m_desc, true);
    this.PlayAnim(n"life_path_btn_highlight_intro");
    this.translationAnimationCtrl.SetBaseText("...");
    this.translationAnimationCtrl = inkWidgetRef.GetController(this.m_desc) as inkTextReplaceController;
    this.translationAnimationCtrl.SetTargetText(this.localizedText);
    this.translationAnimationCtrl.PlaySetAnimation();
    inkVideoRef.Play(this.m_video);
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_desc, false);
    this.PlayAnim(n"life_path_btn_highlight_outro");
    inkVideoRef.Stop(this.m_video);
  }

  public final func PlayAnim(animName: CName, opt callBack: CName) -> Void {
    if this.m_animationProxy.IsPlaying() {
      this.m_animationProxy.Stop();
    };
    this.m_animationProxy = this.PlayLibraryAnimation(animName);
    if IsDefined(this.m_animationProxy) {
      this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, callBack);
    };
  }
}
