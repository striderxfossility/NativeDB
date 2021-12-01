
public native class gameuiPhotoModeStickersController extends inkGameController {

  private edit let m_stickerLibraryId: CName;

  private edit let m_stickersRoot: inkWidgetRef;

  private edit let m_frameRoot: inkWidgetRef;

  private edit let m_backgroundViewRoot: inkWidgetRef;

  private let m_stickers: array<wref<inkWidget>>;

  private let m_frame: wref<inkWidget>;

  private let m_frameLogic: wref<PhotoModeFrame>;

  private let m_currentHovered: Int32;

  private let m_currentMouseDrag: Int32;

  private let m_currentMouseRotate: Int32;

  private let m_stickerDragStartRotation: Float;

  private let m_stickerDragStartScale: Vector2;

  private let m_stickerDragStartPos: Vector2;

  private let m_mouseDragStartPos: Vector2;

  private let m_mouseDragCurrentPos: Vector2;

  private let m_currentSticker: Int32;

  private let m_stickerMove: Vector2;

  private let m_stickerRotation: Float;

  private let m_stickerScale: Float;

  private let m_stickersAreaSize: Vector2;

  private let m_cursorInputEnabled: Bool;

  private let m_editorEnabled: Bool;

  private let m_root: wref<inkCanvas>;

  private let m_isInPhotoMode: Bool;

  public final native func OnStickerTransformChanged(stickerIndex: Int32, stickerPosition: Vector2, stickerScale: Float, stickerRotation: Float) -> Void;

  public final native func OnMouseHover(stickerIndex: Int32) -> Void;

  protected cb func OnInitialize() -> Bool {
    this.m_root = this.GetRootWidget() as inkCanvas;
    this.m_stickersAreaSize = this.m_root.GetSize();
    this.ResetState();
    this.m_editorEnabled = false;
    this.m_isInPhotoMode = false;
    this.RegisterToCallback(n"OnResetStickers", this, n"OnResetStickers");
    this.RegisterToCallback(n"OnSetStickerImage", this, n"OnSetStickerImage");
    this.RegisterToCallback(n"OnSetSetSelectedSticker", this, n"OnSetSetSelectedSticker");
    this.RegisterToCallback(n"OnSetFrameImage", this, n"OnSetFrameImage");
    this.RegisterToCallback(n"OnSetBackground", this, n"OnSetBackground");
  }

  protected final func ResetState() -> Void {
    this.m_currentSticker = -1;
    this.m_currentHovered = -1;
    this.m_currentMouseDrag = -1;
    this.m_currentMouseRotate = -1;
    this.m_stickerDragStartRotation = 0.00;
    this.m_cursorInputEnabled = true;
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromCallback(n"OnResetStickers", this, n"OnResetStickers");
    this.UnregisterFromCallback(n"OnSetStickerImage", this, n"OnSetStickerImage");
    this.UnregisterFromCallback(n"OnSetSetSelectedSticker", this, n"OnSetSetSelectedSticker");
    this.UnregisterFromCallback(n"OnSetFrameImage", this, n"OnSetFrameImage");
    this.UnregisterFromCallback(n"OnSetBackground", this, n"OnSetBackground");
  }

  protected cb func OnEnterPhotoMode() -> Bool {
    let slotsCount: Int32 = TweakDBInterface.GetInt(t"photo_mode.stickers.stickerSlotsCount", 10);
    let i: Int32 = 0;
    while i < slotsCount {
      this.AddSticker();
      i += 1;
    };
    this.ResetState();
    this.m_isInPhotoMode = true;
  }

  protected cb func OnExitPhotoMode() -> Bool {
    let frameRootCompund: wref<inkCompoundWidget>;
    this.m_isInPhotoMode = false;
    let stickersRootCompund: wref<inkCompoundWidget> = inkWidgetRef.Get(this.m_stickersRoot) as inkCompoundWidget;
    let i: Int32 = 0;
    while i < ArraySize(this.m_stickers) {
      stickersRootCompund.RemoveChild(this.m_stickers[i]);
      i += 1;
    };
    ArrayClear(this.m_stickers);
    if this.m_frame != null {
      frameRootCompund = inkWidgetRef.Get(this.m_frameRoot) as inkCompoundWidget;
      frameRootCompund.RemoveChild(this.m_frame);
      this.m_frame = null;
      this.m_frameLogic = null;
    };
    inkWidgetRef.SetVisible(this.m_backgroundViewRoot, false);
    this.ResetState();
  }

  protected cb func OnEnableStickerEditor() -> Bool {
    this.m_editorEnabled = true;
    this.m_stickersAreaSize = this.m_root.GetSize();
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnStickersButtonRelease");
    this.RegisterToGlobalInputCallback(n"OnPostOnHold", this, n"OnStickersButtonHold");
    this.RegisterToGlobalInputCallback(n"OnPostOnPress", this, n"OnStickersButtonPress");
    this.RegisterToGlobalInputCallback(n"OnPostOnAxis", this, n"OnStickersAxisInput");
  }

  protected cb func OnDisableStickerEditor() -> Bool {
    this.m_editorEnabled = false;
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnStickersButtonRelease");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnHold", this, n"OnStickersButtonHold");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnPress", this, n"OnStickersButtonPress");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnAxis", this, n"OnStickersAxisInput");
    this.ResetStickerCursorState();
  }

  protected final func ResetStickerCursorState() -> Void {
    if this.m_currentMouseDrag >= 0 {
      this.m_stickers[this.m_currentMouseDrag].SetOpacity(1.00);
      this.m_currentMouseDrag = -1;
    };
    if this.m_currentMouseRotate >= 0 {
      this.m_stickers[this.m_currentMouseRotate].SetOpacity(1.00);
      this.m_currentMouseRotate = -1;
    };
    if this.m_currentHovered >= 0 {
      this.m_stickers[this.m_currentHovered].SetOpacity(1.00);
      this.m_currentHovered = -1;
      this.OnMouseHover(this.m_currentHovered);
    };
  }

  protected cb func OnCursorInputEnabled(enable: Bool) -> Bool {
    if !enable {
      this.ResetStickerCursorState();
    };
    this.m_cursorInputEnabled = enable;
  }

  protected cb func OnStickersButtonRelease(e: ref<inkPointerEvent>) -> Bool {
    let opacity: Float = this.m_currentHovered == -1 ? 1.00 : 0.65;
    if this.m_cursorInputEnabled && this.m_editorEnabled {
      if e.IsAction(n"PhotoMode_CameraMouseMove") {
        if this.m_currentMouseDrag >= 0 {
          this.m_stickers[this.m_currentMouseDrag].SetOpacity(opacity);
          this.m_currentMouseDrag = -1;
        };
      };
      if e.IsAction(n"PhotoMode_CameraMouseRotation") {
        if this.m_currentMouseRotate >= 0 {
          this.m_stickers[this.m_currentMouseRotate].SetOpacity(opacity);
          this.m_currentMouseRotate = -1;
        };
      };
    };
  }

  protected cb func OnStickersButtonHold(e: ref<inkPointerEvent>) -> Bool {
    if this.m_cursorInputEnabled && this.m_editorEnabled {
      if e.IsAction(n"PhotoMode_CameraMouseMove") {
        if this.m_currentMouseDrag >= 0 {
          this.m_mouseDragCurrentPos = e.GetScreenSpacePosition();
        };
      };
      if e.IsAction(n"PhotoMode_CameraMouseRotation") {
        if this.m_currentMouseRotate >= 0 {
          this.m_mouseDragCurrentPos = e.GetScreenSpacePosition();
        };
      };
    };
  }

  protected cb func OnStickersButtonPress(e: ref<inkPointerEvent>) -> Bool {
    let margin: inkMargin;
    if this.m_cursorInputEnabled && this.m_editorEnabled {
      if this.m_currentHovered >= 0 {
        if e.IsAction(n"PhotoMode_CameraMouseMove") {
          if this.m_currentMouseDrag == -1 && this.m_currentMouseRotate == -1 {
            this.m_currentMouseDrag = this.m_currentHovered;
            this.m_mouseDragStartPos = e.GetScreenSpacePosition();
            this.m_mouseDragCurrentPos = e.GetScreenSpacePosition();
            margin = this.m_stickers[this.m_currentMouseDrag].GetMargin();
            this.m_stickerDragStartPos.X = margin.left;
            this.m_stickerDragStartPos.Y = margin.top;
          };
        };
        if e.IsAction(n"PhotoMode_CameraMouseRotation") {
          if this.m_currentMouseDrag == -1 && this.m_currentMouseRotate == -1 {
            this.m_currentMouseRotate = this.m_currentHovered;
            this.m_mouseDragStartPos = e.GetScreenSpacePosition();
            this.m_mouseDragCurrentPos = e.GetScreenSpacePosition();
            this.m_stickerDragStartRotation = this.m_stickers[this.m_currentMouseRotate].GetRotation();
            this.m_stickerDragStartScale = this.m_stickers[this.m_currentMouseRotate].GetScale();
            margin = this.m_stickers[this.m_currentMouseRotate].GetMargin();
            this.m_stickerDragStartPos.X = margin.left;
            this.m_stickerDragStartPos.Y = margin.top;
          };
        };
      };
    };
  }

  protected cb func OnStickersAxisInput(e: ref<inkPointerEvent>) -> Bool {
    let amount: Float;
    if this.m_currentSticker >= 0 {
      amount = e.GetAxisData();
      if e.IsAction(n"PhotoMode_CameraMovementX") {
        this.m_stickerMove.X += amount;
      } else {
        if e.IsAction(n"PhotoMode_CameraMovementY") {
          this.m_stickerMove.Y -= amount;
        } else {
          if e.IsAction(n"PhotoMode_CameraRotationX") {
            this.m_stickerRotation += amount;
          } else {
            if e.IsAction(n"PhotoMode_CraneUp") {
              this.m_stickerScale += amount;
            } else {
              if e.IsAction(n"PhotoMode_CraneDown") {
                this.m_stickerScale -= amount;
              };
            };
          };
        };
      };
    };
  }

  protected final func DiffAngle(a: Float, b: Float) -> Float {
    let diff: Float = b - a;
    while diff < -180.00 {
      diff += 360.00;
    };
    while diff > 180.00 {
      diff -= 360.00;
    };
    return diff;
  }

  protected final func RotateScaleSticker(sticker: ref<inkWidget>) -> Void {
    let cursorPos: Vector2;
    let cursorStartPos: Vector2;
    let offset: Vector4;
    let startOffset: Vector4;
    let rootScale: Vector2 = this.GetRootWidget().GetScale();
    cursorPos.X = this.m_mouseDragCurrentPos.X / rootScale.X - this.m_stickersAreaSize.X * 0.50;
    cursorPos.Y = this.m_mouseDragCurrentPos.Y / rootScale.Y - this.m_stickersAreaSize.Y * 0.50;
    cursorStartPos.X = this.m_mouseDragStartPos.X / rootScale.X - this.m_stickersAreaSize.X * 0.50;
    cursorStartPos.Y = this.m_mouseDragStartPos.Y / rootScale.Y - this.m_stickersAreaSize.Y * 0.50;
    offset.X = cursorPos.X - this.m_stickerDragStartPos.X;
    offset.Y = cursorPos.Y - this.m_stickerDragStartPos.Y;
    offset.Z = offset.W = 0.00;
    startOffset.X = cursorStartPos.X - this.m_stickerDragStartPos.X;
    startOffset.Y = cursorStartPos.Y - this.m_stickerDragStartPos.Y;
    startOffset.Z = startOffset.W = 0.00;
    let angle: Float = Rad2Deg(-AtanF(-offset.Y, offset.X));
    let startAngle: Float = Rad2Deg(-AtanF(-startOffset.Y, startOffset.X));
    let scale: Float = this.m_stickerDragStartScale.X * Vector4.Length(offset) / Vector4.Length(startOffset);
    scale = ClampF(scale, 0.50, 1.50);
    sticker.SetRotation(this.m_stickerDragStartRotation + this.DiffAngle(startAngle, angle));
    sticker.SetScale(new Vector2(scale, scale));
  }

  protected cb func OnForceStickerTransform(stickerIndex: Int32, position: Vector2, scale: Float, rotation: Float) -> Bool {
    let margin: inkMargin = this.m_stickers[stickerIndex].GetMargin();
    margin.left = position.X;
    margin.top = position.Y;
    this.m_stickers[stickerIndex].SetMargin(margin);
    this.m_stickers[stickerIndex].SetRotation(rotation);
    this.m_stickers[stickerIndex].SetScale(new Vector2(scale, scale));
    this.OnStickerTransformChanged(stickerIndex, position, scale, rotation);
  }

  protected cb func OnUpdateStickers(timeDelta: Float) -> Bool {
    let margin: inkMargin;
    let rootScale: Vector2;
    let rotation: Float;
    let scale: Vector2;
    let sticker: ref<inkWidget>;
    if this.m_isInPhotoMode {
      rootScale = this.GetRootWidget().GetScale();
      if this.m_currentMouseRotate >= 0 {
        sticker = this.m_stickers[this.m_currentMouseRotate];
        this.RotateScaleSticker(sticker);
        margin = sticker.GetMargin();
        rotation = sticker.GetRotation();
        scale = sticker.GetScale();
        this.OnStickerTransformChanged(this.m_currentMouseRotate, new Vector2(margin.left, margin.top), scale.X, rotation);
      } else {
        if this.m_currentMouseDrag >= 0 {
          sticker = this.m_stickers[this.m_currentMouseDrag];
          margin = sticker.GetMargin();
          rotation = sticker.GetRotation();
          scale = sticker.GetScale();
          margin.left = this.m_stickerDragStartPos.X + (this.m_mouseDragCurrentPos.X - this.m_mouseDragStartPos.X) / rootScale.X;
          margin.top = this.m_stickerDragStartPos.Y + (this.m_mouseDragCurrentPos.Y - this.m_mouseDragStartPos.Y) / rootScale.Y;
          margin.left = ClampF(margin.left, -this.m_stickersAreaSize.X * 0.50, this.m_stickersAreaSize.X * 0.50);
          margin.top = ClampF(margin.top, -this.m_stickersAreaSize.Y * 0.50, this.m_stickersAreaSize.Y * 0.50);
          sticker.SetMargin(margin);
          this.OnStickerTransformChanged(this.m_currentMouseDrag, new Vector2(margin.left, margin.top), scale.X, rotation);
        } else {
          if this.m_currentSticker >= 0 {
            sticker = this.m_stickers[this.m_currentSticker];
            margin = sticker.GetMargin();
            rotation = sticker.GetRotation();
            scale = sticker.GetScale();
            margin.left += this.m_stickerMove.X * timeDelta * 1500.00;
            margin.top += this.m_stickerMove.Y * timeDelta * 1500.00;
            margin.left = ClampF(margin.left, -this.m_stickersAreaSize.X * 0.50, this.m_stickersAreaSize.X * 0.50);
            margin.top = ClampF(margin.top, -this.m_stickersAreaSize.Y * 0.50, this.m_stickersAreaSize.Y * 0.50);
            rotation += this.m_stickerRotation * timeDelta * 100.00;
            scale.X += this.m_stickerScale * timeDelta * 2.00;
            scale.Y += this.m_stickerScale * timeDelta * 2.00;
            scale.X = ClampF(scale.X, 0.50, 1.50);
            scale.Y = ClampF(scale.Y, 0.50, 1.50);
            sticker.SetMargin(margin);
            sticker.SetRotation(rotation);
            sticker.SetScale(scale);
            this.OnStickerTransformChanged(this.m_currentSticker, new Vector2(margin.left, margin.top), scale.X, rotation);
            this.m_stickerMove.X = 0.00;
            this.m_stickerMove.Y = 0.00;
            this.m_stickerRotation = 0.00;
            this.m_stickerScale = 0.00;
          };
        };
      };
      if IsDefined(this.m_frameLogic) {
        this.m_frameLogic.Update(timeDelta);
      };
    };
  }

  protected cb func OnSetSetSelectedSticker(stickerIndex: Int32) -> Bool {
    if stickerIndex >= 0 {
      this.m_currentSticker = stickerIndex;
    } else {
      this.m_currentSticker = -1;
    };
  }

  protected cb func OnSetStickerImage(stickerIndex: Uint32, atlasPath: ResRef, imagePart: CName, imageIndex: Int32) -> Bool {
    let sticker: ref<PhotoModeSticker>;
    let i: Int32 = Cast(stickerIndex);
    if Equals(imagePart, n"") || !ResRef.IsValid(atlasPath) {
      this.m_stickers[Cast(stickerIndex)].SetVisible(false);
    } else {
      this.m_stickers[i].SetVisible(true);
    };
    sticker = this.m_stickers[i].GetControllerByType(n"PhotoModeSticker") as PhotoModeSticker;
    sticker.SetAtlas(atlasPath);
    sticker.SetImage(imagePart);
  }

  protected cb func OnResetStickers() -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_stickers) {
      this.m_stickers[i].SetVisible(false);
      this.m_stickers[i].SetOpacity(1.00);
      this.m_stickers[i].SetMargin(0.00, 0.00, 0.00, 0.00);
      this.m_stickers[i].SetRotation(0.00);
      this.m_stickers[i].SetScale(new Vector2(1.00, 1.00));
      i += 1;
    };
    this.m_currentSticker = -1;
    this.m_currentHovered = -1;
    this.m_currentMouseDrag = -1;
    this.m_currentMouseRotate = -1;
    this.OnMouseHover(this.m_currentHovered);
  }

  protected cb func OnSetFrameImage(atlasPath: ResRef, imageParts: array<CName>, libraryItemName: CName, color: Color, flipHorizontal: Bool, flipVertical: Bool) -> Bool {
    let frameRootCompund: wref<inkCompoundWidget>;
    if this.m_frame != null {
      frameRootCompund = inkWidgetRef.Get(this.m_frameRoot) as inkCompoundWidget;
      frameRootCompund.RemoveChild(this.m_frame);
      this.m_frame = null;
      this.m_frameLogic = null;
    };
    if ArraySize(imageParts) > 0 && ResRef.IsValid(atlasPath) {
      this.m_frame = this.AddFrame(libraryItemName);
      this.m_frameLogic = this.m_frame.GetControllerByType(n"PhotoModeFrame") as PhotoModeFrame;
      this.m_frameLogic.SetupScale(this.m_stickersAreaSize);
      this.m_frameLogic.SetAtlas(atlasPath);
      this.m_frameLogic.SetImages(imageParts);
      this.m_frameLogic.SetColor(color);
      this.m_frameLogic.SetFlip(flipHorizontal, flipVertical);
    };
  }

  protected cb func OnSetBackground(enabled: Bool) -> Bool {
    let animDef: ref<inkAnimDef>;
    let animInterp: ref<inkAnimTransparency>;
    if enabled && !inkWidgetRef.IsVisible(this.m_backgroundViewRoot) {
      inkWidgetRef.SetOpacity(this.m_backgroundViewRoot, 0.00);
      animDef = new inkAnimDef();
      animInterp = new inkAnimTransparency();
      animInterp.SetStartTransparency(0.00);
      animInterp.SetEndTransparency(1.00);
      animInterp.SetDuration(0.40);
      animInterp.SetDirection(inkanimInterpolationDirection.To);
      animInterp.SetUseRelativeDuration(true);
      animDef.AddInterpolator(animInterp);
      inkWidgetRef.PlayAnimation(this.m_backgroundViewRoot, animDef);
    };
    inkWidgetRef.SetVisible(this.m_backgroundViewRoot, enabled);
  }

  protected final func AddSticker() -> Void {
    let margin: inkMargin;
    let stickerLogic: ref<PhotoModeSticker>;
    let newSticker: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(this.m_stickersRoot), this.m_stickerLibraryId);
    newSticker.SetAnchorPoint(0.50, 0.50);
    newSticker.SetAnchor(inkEAnchor.Centered);
    newSticker.SetVisible(false);
    margin = newSticker.GetMargin();
    margin.left = -this.m_stickersAreaSize.X * 0.25;
    newSticker.SetMargin(margin);
    stickerLogic = newSticker.GetControllerByType(n"PhotoModeSticker") as PhotoModeSticker;
    stickerLogic.m_stickersController = this;
    ArrayPush(this.m_stickers, newSticker);
  }

  protected final func AddFrame(libraryItem: CName) -> wref<inkWidget> {
    this.m_frame = this.SpawnFromLocal(inkWidgetRef.Get(this.m_frameRoot), libraryItem);
    this.m_frame.SetAnchorPoint(0.50, 0.50);
    this.m_frame.SetAnchor(inkEAnchor.Fill);
    this.m_frame.SetVisible(true);
    this.m_frame.SetOpacity(0.00);
    return this.m_frame;
  }

  public final func StickerHoveredOutByMouse(sticker: wref<inkWidget>) -> Void {
    let i: Int32;
    if this.m_cursorInputEnabled && this.m_editorEnabled {
      i = 0;
      while i < ArraySize(this.m_stickers) {
        if this.m_stickers[i] == sticker && this.m_currentHovered == i {
          this.SetCursorContext(n"Default");
          if this.m_currentMouseRotate == -1 && this.m_currentMouseDrag == -1 {
            this.m_stickers[i].SetOpacity(1.00);
          };
          this.m_currentHovered = -1;
          this.OnMouseHover(this.m_currentHovered);
        } else {
          i += 1;
        };
      };
    };
  }

  public final func StickerHoveredByMouse(sticker: wref<inkWidget>) -> Void {
    let i: Int32;
    if this.m_cursorInputEnabled && this.m_editorEnabled && this.m_currentMouseRotate == -1 && this.m_currentMouseDrag == -1 {
      if this.m_currentHovered >= 0 {
        this.m_stickers[this.m_currentHovered].SetOpacity(1.00);
        this.m_currentHovered = -1;
      };
      i = 0;
      while i < ArraySize(this.m_stickers) {
        if this.m_stickers[i] == sticker {
          this.SetCursorContext(n"Hover");
          this.m_stickers[i].SetOpacity(0.65);
          this.m_currentHovered = i;
        } else {
          i += 1;
        };
      };
      this.OnMouseHover(this.m_currentHovered);
    };
  }
}
