
public class PhotoModeGridButton extends inkToggleController {

  private edit let m_FrameImg: inkImageRef;

  private edit let m_DynamicImg: inkImageRef;

  private edit let m_BgWidget: inkWidgetRef;

  private edit let m_HoverWidget: inkWidgetRef;

  private edit let m_PlusImg: inkImageRef;

  private let m_currentImagePart: CName;

  private let m_atlasRef: ResRef;

  private let m_buttonData: Int32;

  private let m_parentGrid: wref<PhotoModeGridList>;

  private let m_index: Int32;

  private let m_visibleOnGrid: Bool;

  private let m_imageScalingSpeed: Float;

  private let m_opacityScalingSpeed: Float;

  public final func Setup(grid: ref<PhotoModeGridList>, index: Int32) -> Void {
    this.m_parentGrid = grid;
    this.m_index = index;
  }

  protected cb func OnInitialize() -> Bool {
    this.m_buttonData = -1;
    this.m_visibleOnGrid = false;
    this.RegisterToCallback(n"OnRelease", this, n"OnToggleClick");
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHovered");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    this.ButtonStateChanged(false);
    this.m_imageScalingSpeed = 50.00;
    this.m_opacityScalingSpeed = 3.00;
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_parentGrid = null;
    this.UnregisterFromCallback(n"OnRelease", this, n"OnToggleClick");
    this.UnregisterFromCallback(n"OnHoverOver", this, n"OnHovered");
    this.UnregisterFromCallback(n"OnHoverOut", this, n"OnHoverOut");
  }

  protected cb func OnToggleClick(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.m_parentGrid.OnGridButtonAction(this.m_index);
    };
  }

  protected cb func OnHovered(e: ref<inkPointerEvent>) -> Bool {
    if !this.IsToggledVisually() {
      inkWidgetRef.SetVisible(this.m_HoverWidget, true);
    };
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_HoverWidget, false);
  }

  public final func SetImage(atlasPath: ResRef, imagePart: CName) -> Void {
    if Equals(imagePart, n"") || !ResRef.IsValid(atlasPath) {
      inkWidgetRef.SetVisible(this.m_DynamicImg, false);
      inkWidgetRef.SetVisible(this.m_PlusImg, true);
      inkWidgetRef.SetVisible(this.m_FrameImg, true);
    } else {
      inkWidgetRef.SetVisible(this.m_DynamicImg, true);
      inkWidgetRef.SetVisible(this.m_PlusImg, false);
      inkWidgetRef.SetVisible(this.m_FrameImg, false);
    };
    if this.m_visibleOnGrid {
      inkImageRef.SetAtlasResource(this.m_DynamicImg, atlasPath);
      inkImageRef.SetTexturePart(this.m_DynamicImg, imagePart);
    };
    inkWidgetRef.SetScale(this.m_DynamicImg, new Vector2(0.00, 0.00));
    inkWidgetRef.SetOpacity(this.m_DynamicImg, 0.10);
    this.m_atlasRef = atlasPath;
    this.m_currentImagePart = imagePart;
  }

  public final func SetData(buttonData: Int32) -> Void {
    this.m_buttonData = buttonData;
  }

  public final func GetData() -> Int32 {
    return this.m_buttonData;
  }

  public final func IsToggledVisually() -> Bool {
    return inkWidgetRef.IsVisible(this.m_BgWidget);
  }

  public final func ButtonStateChanged(selected: Bool) -> Void {
    if selected {
      inkWidgetRef.SetVisible(this.m_BgWidget, true);
    } else {
      inkWidgetRef.SetVisible(this.m_BgWidget, false);
    };
  }

  public final func OnVisibilityOnGridChanged(visible: Bool) -> Void {
    if Equals(this.m_visibleOnGrid, visible) {
      return;
    };
    if visible {
      inkImageRef.SetAtlasResource(this.m_DynamicImg, this.m_atlasRef);
      inkImageRef.SetTexturePart(this.m_DynamicImg, this.m_currentImagePart);
      inkWidgetRef.SetVisible(this.m_DynamicImg, true);
    } else {
      inkWidgetRef.SetScale(this.m_DynamicImg, new Vector2(0.00, 0.00));
      inkWidgetRef.SetOpacity(this.m_DynamicImg, 0.10);
      inkWidgetRef.SetVisible(this.m_DynamicImg, false);
    };
    this.m_visibleOnGrid = visible;
  }

  public final func UpdateSize(timeDelta: Float) -> Void {
    let currentScale: Vector2;
    let imageSize: Vector2;
    let scaleX: Float;
    let scaleY: Float;
    let t: Float;
    if this.m_visibleOnGrid && NotEquals(this.m_currentImagePart, n"") && inkImageRef.IsTexturePartExist(this.m_DynamicImg, this.m_currentImagePart) {
      currentScale = inkWidgetRef.GetScale(this.m_DynamicImg);
      imageSize = inkWidgetRef.GetDesiredSize(this.m_DynamicImg);
      scaleX = imageSize.X / MaxF(imageSize.X, imageSize.Y);
      scaleY = imageSize.Y / MaxF(imageSize.X, imageSize.Y);
      t = ClampF(this.m_imageScalingSpeed * timeDelta, 0.00, 1.00);
      inkWidgetRef.SetScale(this.m_DynamicImg, new Vector2(LerpF(t, currentScale.X, scaleX), LerpF(t, currentScale.Y, scaleY)));
      inkWidgetRef.SetOpacity(this.m_DynamicImg, ClampF(inkWidgetRef.GetOpacity(this.m_DynamicImg) + this.m_opacityScalingSpeed * timeDelta, 0.00, 1.00));
    };
  }
}
