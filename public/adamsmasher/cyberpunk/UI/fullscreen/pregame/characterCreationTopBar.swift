
public class CharacterCreationPersistantElements extends inkLogicController {

  private edit let m_headerHolder: inkCompoundRef;

  private edit let m_LBBtn: inkWidgetRef;

  private edit let m_RBBtn: inkWidgetRef;

  private edit let m_fluffHolderRight: inkCompoundRef;

  private edit let m_fluffHolderDown: inkCompoundRef;

  private edit let m_fluffHolderLeft: inkCompoundRef;

  private edit let m_fluffText1: inkTextRef;

  private edit let m_fluffTextRight: inkTextRef;

  private edit let m_fluffTextDown: inkTextRef;

  private edit let m_fluffTextLeft: inkTextRef;

  private let m_headers: array<wref<CharacterCreationTopBarHeader>>;

  private let m_selectedHeader: wref<CharacterCreationTopBarHeader>;

  @default(CharacterCreationPersistantElements, 1800)
  public const let c_fluffMaxX: Float;

  @default(CharacterCreationPersistantElements, 300)
  public const let c_fluffMinY: Float;

  @default(CharacterCreationPersistantElements, 2000)
  public const let c_fluffMaxY: Float;

  protected cb func OnInitialize() -> Bool {
    let currLogic: wref<CharacterCreationTopBarHeader>;
    let i: Int32;
    this.CreateHeader("UI-Cyberpunk-Fullscreen-CharacterCreation-Life_Path", n"icon_backstory");
    this.CreateHeader("UI-Cyberpunk-Fullscreen-CharacterCreation-Body", n"icon_body");
    this.CreateHeader("UI-Cyberpunk-Fullscreen-CharacterCreation-Appearance", n"icon_appearence");
    this.CreateHeader("UI-Cyberpunk-Fullscreen-CharacterCreation-Attributes", n"icon_stats");
    i = 0;
    while i < ArraySize(this.m_headers) {
      currLogic = this.m_headers[i];
      currLogic.m_root.SetState(n"Unselected");
      i += 1;
    };
    this.RegisterToCallback(n"OnChangeToHeader_00", this, n"OnChangeToHeader_00");
    this.RegisterToGlobalInputCallback(n"OnPostOnAxis", this, n"OnAxisInput");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelative", this, n"OnRelativeInput");
    this.PlaySound(n"GameMenu", n"OnOpen");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnAxis", this, n"OnAxisInput");
    this.UnregisterFromCallback(n"OnChangeToHeader_00", this, n"OnChangeToHeader_00");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelative", this, n"OnRelativeInput");
    this.PlaySound(n"GameMenu", n"OnClose");
  }

  public final func ChangeSelectedHeader(selectedIndex: Int32) -> Void {
    let currLogic: wref<CharacterCreationTopBarHeader>;
    inkWidgetRef.SetVisible(this.m_LBBtn, true);
    inkWidgetRef.SetVisible(this.m_RBBtn, true);
    if IsDefined(this.m_selectedHeader) {
      this.m_selectedHeader.Unselect();
    };
    if IsDefined(this.m_headers[selectedIndex]) {
      currLogic = this.m_headers[selectedIndex];
      this.m_selectedHeader = currLogic;
      this.m_selectedHeader.Select();
    };
  }

  public final func ChangeNavigationButtonVisibility(previousBtnAvailable: Bool, nextBtnAvailable: Bool) -> Void {
    inkWidgetRef.SetVisible(this.m_LBBtn, previousBtnAvailable);
    inkWidgetRef.SetVisible(this.m_RBBtn, nextBtnAvailable);
  }

  public final func CreateHeader(label: String, icon: CName) -> Void {
    let currButton: ref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_headerHolder), n"top_bar_header");
    let currLogic: wref<CharacterCreationTopBarHeader> = currButton.GetController() as CharacterCreationTopBarHeader;
    currLogic.SetData(label, icon);
    ArrayPush(this.m_headers, currLogic);
  }

  protected cb func OnChangeToHeader_00(e: wref<inkWidget>) -> Bool {
    this.ChangeSelectedHeader(0);
  }

  protected cb func OnAxisInput(e: ref<inkPointerEvent>) -> Bool {
    this.SetFluff(e);
  }

  protected cb func OnRelativeInput(e: ref<inkPointerEvent>) -> Bool {
    this.SetFluff(e);
  }

  public final func SetFluff(e: ref<inkPointerEvent>) -> Void {
    let inkMarginFluffLeft: inkMargin;
    let inkMarginFluffRight: inkMargin;
    let value: Vector2 = e.GetScreenSpacePosition();
    let clampedValueX: Float = ClampF(value.X, 0.00, this.c_fluffMaxX);
    let clampedValueY: Float = ClampF(value.Y, this.c_fluffMinY, this.c_fluffMaxY);
    inkWidgetRef.SetMargin(this.m_fluffHolderDown, new inkMargin(clampedValueX, 0.00, 0.00, 0.00));
    inkMarginFluffRight = inkWidgetRef.GetMargin(this.m_fluffHolderRight);
    inkMarginFluffLeft = inkWidgetRef.GetMargin(this.m_fluffHolderLeft);
    inkWidgetRef.SetMargin(this.m_fluffHolderRight, new inkMargin(0.00, clampedValueY, inkMarginFluffRight.right, 0.00));
    inkWidgetRef.SetMargin(this.m_fluffHolderLeft, new inkMargin(inkMarginFluffLeft.left, clampedValueY, 0.00, 0.00));
    inkTextRef.SetText(this.m_fluffText1, "OB " + ToString(value.X) + " " + ToString(value.X) + " " + ToString(value.X) + " CP");
    inkTextRef.SetText(this.m_fluffTextRight, ToString(Cast(value.Y)));
    inkTextRef.SetText(this.m_fluffTextDown, ToString(Cast(value.X)));
    inkTextRef.SetText(this.m_fluffTextLeft, ToString(Cast(value.Y)));
  }
}

public class CharacterCreationTopBarHeader extends inkButtonController {

  private edit let m_icon: inkImageRef;

  private edit let m_label: inkTextRef;

  public let m_root: wref<inkWidget>;

  private let m_animationProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget();
  }

  protected cb func OnUninitialize() -> Bool;

  public final func SetData(label: String, icon: CName) -> Void {
    inkImageRef.SetTexturePart(this.m_icon, icon);
    inkTextRef.SetText(this.m_label, label);
  }

  public final func Select() -> Void {
    this.PlayAnim(n"Select");
  }

  public final func Unselect() -> Void {
    this.PlayAnim(n"Unselect");
  }

  public final func PlayAnim(animName: CName) -> Void {
    if IsDefined(this.m_animationProxy) && this.m_animationProxy.IsPlaying() {
      this.m_animationProxy.Stop();
    };
    this.m_animationProxy = this.PlayLibraryAnimation(animName);
  }
}
