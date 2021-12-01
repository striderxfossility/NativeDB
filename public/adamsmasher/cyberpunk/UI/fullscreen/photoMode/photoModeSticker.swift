
public class PhotoModeSticker extends inkLogicController {

  private edit let m_image: inkImageRef;

  public let m_stickersController: wref<gameuiPhotoModeStickersController>;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.RegisterToCallback(this.m_image, n"OnHoverOver", this, n"OnStickerHovered");
    inkWidgetRef.RegisterToCallback(this.m_image, n"OnHoverOut", this, n"OnStickerHoverOut");
  }

  public final func SetAtlas(atlasPath: ResRef) -> Void {
    inkImageRef.SetAtlasResource(this.m_image, atlasPath);
  }

  public final func SetImage(imagePart: CName) -> Void {
    inkImageRef.SetTexturePart(this.m_image, imagePart);
  }

  protected cb func OnStickerHovered(e: ref<inkPointerEvent>) -> Bool {
    this.m_stickersController.StickerHoveredByMouse(this.GetRootWidget());
  }

  protected cb func OnStickerHoverOut(e: ref<inkPointerEvent>) -> Bool {
    this.m_stickersController.StickerHoveredOutByMouse(this.GetRootWidget());
  }
}
