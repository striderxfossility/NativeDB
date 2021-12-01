
public abstract native class inkPreviewGameController extends gameuiMenuGameController {

  protected edit let m_isRotatable: Bool;

  @default(inkInventoryPuppetPreviewGameController, 60.0f)
  @default(inkPreviewGameController, 30.0f)
  protected edit let m_rotationSpeed: Float;

  public final native func Rotate(yaw: Float) -> Void;

  public final native func RotateVector(value: Vector3) -> Void;

  protected cb func OnInitialize() -> Bool {
    if this.m_isRotatable {
      this.RegisterToGlobalInputCallback(n"OnPostOnAxis", this, n"OnAxisInput");
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if this.m_isRotatable {
      this.UnregisterFromGlobalInputCallback(n"OnPostOnAxis", this, n"OnAxisInput");
    };
  }

  protected func HandleAxisInput(e: ref<inkPointerEvent>) -> Void {
    let amount: Float = e.GetAxisData();
    if e.IsAction(n"left_trigger") || e.IsAction(n"character_preview_rotate") {
      this.Rotate(amount * -this.m_rotationSpeed);
    } else {
      if e.IsAction(n"right_trigger") || e.IsAction(n"character_preview_rotate") {
        this.Rotate(amount * this.m_rotationSpeed);
      };
    };
  }

  protected cb func OnAxisInput(e: ref<inkPointerEvent>) -> Bool {
    this.HandleAxisInput(e);
  }
}

public native class inkPuppetPreviewGameController extends inkPreviewGameController {

  public final native func GetGamePuppet() -> wref<gamePuppet>;

  protected cb func OnPuppetAttached() -> Bool {
    this.SendAnimData();
  }

  private func SendAnimData() -> Void {
    let animFeature: ref<AnimFeature_Paperdoll>;
    this.GetAnimFeature(animFeature);
    AnimationControllerComponent.ApplyFeature(this.GetGamePuppet(), n"Paperdoll", animFeature);
  }

  private func GetAnimFeature(out animFeature: ref<AnimFeature_Paperdoll>) -> Void {
    animFeature = new AnimFeature_Paperdoll();
  }
}

public native class inkGenderSelectionPuppetPreviewGameController extends inkPuppetPreviewGameController {

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
  }

  private func GetAnimFeature(out animFeature: ref<AnimFeature_Paperdoll>) -> Void {
    animFeature = new AnimFeature_Paperdoll();
    animFeature.genderSelection = true;
  }
}

public native class inkCharacterCreationPuppetPreviewGameController extends inkPuppetPreviewGameController {

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.PlayLibraryAnimation(n"intro");
  }

  private func GetAnimFeature(out animFeature: ref<AnimFeature_Paperdoll>) -> Void {
    animFeature = new AnimFeature_Paperdoll();
    animFeature.characterCreation = true;
  }

  protected cb func OnSetCameraSetupEvent(index: Uint32, slotName: CName) -> Bool {
    let animFeature: ref<AnimFeature_Paperdoll> = new AnimFeature_Paperdoll();
    if Equals(slotName, n"UI_HeadPreview") || Equals(slotName, n"UI_Hairs") {
      animFeature.characterCreation_Head = true;
    } else {
      if Equals(slotName, n"UI_Teeth") {
        animFeature.characterCreation_Head = true;
        animFeature.characterCreation_Teeth = true;
      } else {
        if Equals(slotName, n"UI_FingerNails") {
          animFeature.characterCreation_Nails = true;
        } else {
          if Equals(slotName, n"Summary_Preview") {
            animFeature.characterCreation_Summary = true;
          } else {
            if Equals(slotName, n"Gender_Preview") {
              animFeature.genderSelection = true;
            } else {
              animFeature.characterCreation = true;
            };
          };
        };
      };
    };
    AnimationControllerComponent.ApplyFeature(this.GetGamePuppet(), n"Paperdoll", animFeature);
  }
}

public native class inkInventoryPuppetPreviewGameController extends inkPuppetPreviewGameController {

  private edit let m_collider: inkWidgetRef;

  private let m_rotationIsMouseDown: Bool;

  @default(inkInventoryPuppetPreviewGameController, 40.0f)
  private let m_maxMousePointerOffset: Float;

  @default(inkInventoryPuppetPreviewGameController, 250.0f)
  private let m_mouseRotationSpeed: Float;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    inkWidgetRef.RegisterToCallback(this.m_collider, n"OnPress", this, n"OnMouseDown");
    this.RegisterToGlobalInputCallback(n"OnPreOnRelease", this, n"OnGlobalRelease");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelative", this, n"OnRelativeInput");
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
    inkWidgetRef.UnregisterFromCallback(this.m_collider, n"OnPress", this, n"OnMouseDown");
    this.UnregisterFromGlobalInputCallback(n"OnPreOnRelease", this, n"OnGlobalRelease");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelative", this, n"OnRelativeInput");
  }

  protected cb func OnMouseDown(e: ref<inkPointerEvent>) -> Bool {
    let evt: ref<inkMenuLayer_SetCursorVisibility>;
    if e.IsAction(n"mouse_left") {
      this.m_rotationIsMouseDown = true;
      evt = new inkMenuLayer_SetCursorVisibility();
      evt.Init(false);
      this.QueueEvent(evt);
    };
  }

  protected cb func OnGlobalRelease(e: ref<inkPointerEvent>) -> Bool {
    let evt: ref<inkMenuLayer_SetCursorVisibility>;
    if this.m_rotationIsMouseDown && e.IsAction(n"mouse_left") {
      e.Consume();
      this.m_rotationIsMouseDown = false;
      evt = new inkMenuLayer_SetCursorVisibility();
      evt.Init(true);
      this.QueueEvent(evt);
    };
  }

  protected cb func OnRelativeInput(e: ref<inkPointerEvent>) -> Bool {
    let ratio: Float;
    let velocity: Float;
    let offset: Float = e.GetAxisData();
    if offset > 0.00 {
      ratio = ClampF(offset / this.m_maxMousePointerOffset, 0.50, 1.00);
    } else {
      ratio = ClampF(offset / this.m_maxMousePointerOffset, -1.00, -0.50);
    };
    velocity = ratio * this.m_mouseRotationSpeed;
    if this.m_rotationIsMouseDown {
      if e.IsAction(n"mouse_x") {
        this.Rotate(velocity);
      };
    };
  }

  private func GetAnimFeature(out animFeature: ref<AnimFeature_Paperdoll>) -> Void {
    animFeature = new AnimFeature_Paperdoll();
    animFeature.inventoryScreen = true;
  }

  protected cb func OnSetCameraSetupEvent(index: Uint32, slotName: CName) -> Bool {
    let animFeature: ref<AnimFeature_Paperdoll> = new AnimFeature_Paperdoll();
    let zoomArea: InventoryPaperdollZoomArea = IntEnum(index);
    animFeature.inventoryScreen = Equals(zoomArea, InventoryPaperdollZoomArea.Default);
    animFeature.inventoryScreen_Weapon = Equals(zoomArea, InventoryPaperdollZoomArea.Weapon);
    animFeature.inventoryScreen_Legs = Equals(zoomArea, InventoryPaperdollZoomArea.Legs);
    animFeature.inventoryScreen_Feet = Equals(zoomArea, InventoryPaperdollZoomArea.Feet);
    animFeature.inventoryScreen_Cyberware = Equals(zoomArea, InventoryPaperdollZoomArea.Cyberware);
    animFeature.inventoryScreen_QuickSlot = Equals(zoomArea, InventoryPaperdollZoomArea.QuickSlot);
    animFeature.inventoryScreen_Consumable = Equals(zoomArea, InventoryPaperdollZoomArea.Consumable);
    animFeature.inventoryScreen_Outfit = Equals(zoomArea, InventoryPaperdollZoomArea.Outfit);
    animFeature.inventoryScreen_Head = Equals(zoomArea, InventoryPaperdollZoomArea.Head);
    animFeature.inventoryScreen_Face = Equals(zoomArea, InventoryPaperdollZoomArea.Face);
    animFeature.inventoryScreen_InnerChest = Equals(zoomArea, InventoryPaperdollZoomArea.InnerChest);
    animFeature.inventoryScreen_OuterChest = Equals(zoomArea, InventoryPaperdollZoomArea.OuterChest);
    AnimationControllerComponent.ApplyFeature(this.GetGamePuppet(), n"Paperdoll", animFeature);
  }
}
