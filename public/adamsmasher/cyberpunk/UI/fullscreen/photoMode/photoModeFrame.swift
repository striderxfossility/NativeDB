
public class PhotoModeFrame extends inkLogicController {

  private edit const let m_images: array<inkImageRef>;

  private edit let m_keepImageAspectRatio: Bool;

  public let m_stickersController: wref<gameuiPhotoModeStickersController>;

  private let m_currentImagePart: CName;

  private let m_opacity: Float;

  public final func SetupScale(rootSize: Vector2) -> Void {
    let i: Int32;
    let scale: Float;
    let aspect: Float = rootSize.X / rootSize.Y;
    let minAspect: Float = 16.00 / 9.00;
    if this.m_keepImageAspectRatio && aspect < minAspect {
      scale = minAspect / aspect;
    } else {
      scale = 1.00;
    };
    i = 0;
    while i < ArraySize(this.m_images) {
      inkWidgetRef.SetScale(this.m_images[i], new Vector2(scale, scale));
      i += 1;
    };
  }

  public final func SetAtlas(atlasPath: ResRef) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_images) {
      inkImageRef.SetAtlasResource(this.m_images[i], atlasPath);
      i += 1;
    };
  }

  public final func SetImages(imageParts: array<CName>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(imageParts) && i < ArraySize(this.m_images) {
      inkImageRef.SetTexturePart(this.m_images[i], imageParts[i]);
      i += 1;
    };
    this.m_currentImagePart = imageParts[0];
    this.m_opacity = 0.00;
  }

  public final func SetColor(color: Color) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_images) {
      inkWidgetRef.SetTintColor(this.m_images[i], color);
      i += 1;
    };
  }

  public final func SetFlip(horizontal: Bool, vertical: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_images) {
      if horizontal && vertical {
        inkImageRef.SetBrushMirrorType(this.m_images[i], inkBrushMirrorType.Both);
      } else {
        if horizontal {
          inkImageRef.SetBrushMirrorType(this.m_images[i], inkBrushMirrorType.Horizontal);
        } else {
          if vertical {
            inkImageRef.SetBrushMirrorType(this.m_images[i], inkBrushMirrorType.Vertical);
          } else {
            inkImageRef.SetBrushMirrorType(this.m_images[i], inkBrushMirrorType.NoMirror);
          };
        };
      };
      i += 1;
    };
  }

  public final func Update(timeDelta: Float) -> Void {
    if NotEquals(this.m_currentImagePart, n"") && inkImageRef.IsTexturePartExist(this.m_images[0], this.m_currentImagePart) {
      if this.m_opacity < 1.00 {
        this.m_opacity += timeDelta * 6.00;
        if this.m_opacity >= 1.00 {
          this.m_opacity = 1.00;
        };
      };
    } else {
      this.m_opacity = 0.00;
    };
    this.GetRootWidget().SetOpacity(this.m_opacity);
  }
}
