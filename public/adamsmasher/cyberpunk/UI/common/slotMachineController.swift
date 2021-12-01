
public class SlotMachineController extends inkLogicController {

  private edit let m_barrelAnimationID: CName;

  private edit const let m_winAnimationsID: array<CName>;

  private edit let m_looseAnimationID: CName;

  private edit const let m_slotWidgets: array<inkWidgetRef>;

  private edit const let m_imagePresets: array<CName>;

  private edit let m_winChance: Int32;

  @default(SlotMachineController, 100)
  private let m_maxWinChance: Int32;

  private let m_slots: array<wref<SlotMachineSlot>>;

  private let m_barellAnimation: ref<inkAnimProxy>;

  private let m_outcomeAnimation: ref<inkAnimProxy>;

  private let m_shouldWinNextTime: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_winChance = Clamp(this.m_winChance, 0, this.m_maxWinChance);
    this.SetupBarellSlots();
    this.PerformBarellCycle();
  }

  private final func SetupBarellSlots() -> Void {
    let slotMachineSlot: wref<SlotMachineSlot>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_slotWidgets) {
      slotMachineSlot = inkWidgetRef.GetControllerByType(this.m_slotWidgets[i], n"SlotMachineSlot") as SlotMachineSlot;
      slotMachineSlot.SetImagesPresets(this.m_imagePresets);
      ArrayPush(this.m_slots, slotMachineSlot);
      i += 1;
    };
  }

  private final func PerformBarellCycle() -> Void {
    let drawNumber: Int32 = RandRange(0, this.m_maxWinChance);
    if drawNumber >= this.m_winChance {
      this.m_shouldWinNextTime = true;
    } else {
      this.m_shouldWinNextTime = false;
    };
    this.RandomizeBarell();
    this.m_barellAnimation = this.PlayLibraryAnimation(this.m_barrelAnimationID);
    this.m_barellAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnBarellAnimationFinished");
  }

  private final func RandomizeBarell() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_slots) {
      this.m_slots[i].RandomiseImages(this.m_shouldWinNextTime);
      i += 1;
    };
  }

  protected cb func OnBarellAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
    let randomIdx: Int32;
    this.m_barellAnimation.Stop();
    this.m_barellAnimation.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnBarellAnimationFinished");
    if this.m_shouldWinNextTime {
      randomIdx = RandRange(0, ArraySize(this.m_winAnimationsID));
      this.m_outcomeAnimation = this.PlayLibraryAnimation(this.m_winAnimationsID[randomIdx]);
    } else {
      this.m_outcomeAnimation = this.PlayLibraryAnimation(this.m_looseAnimationID);
    };
    this.m_outcomeAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOutcomeAnimationFinished");
  }

  protected cb func OnOutcomeAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.m_outcomeAnimation.Stop();
    this.m_outcomeAnimation.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnOutcomeAnimationFinished");
    this.PerformBarellCycle();
  }
}

public class SlotMachineSlot extends inkLogicController {

  private edit let m_winningRowIndex: Int32;

  private edit const let m_imagesUpper: array<inkImageRef>;

  private edit const let m_imagesLower: array<inkImageRef>;

  private let m_imagePresets: array<CName>;

  protected cb func OnInitialize() -> Bool {
    this.m_winningRowIndex = Clamp(this.m_winningRowIndex, 0, ArraySize(this.m_imagesUpper));
  }

  public final func SetImagesPresets(imagePresets: array<CName>) -> Void {
    this.m_imagePresets = imagePresets;
  }

  public final func RandomiseUpperImages() -> Void {
    let randomIdx: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_imagesUpper) {
      randomIdx = RandRange(0, ArraySize(this.m_imagePresets));
      inkImageRef.SetTexturePart(this.m_imagesUpper[i], this.m_imagePresets[randomIdx]);
      i += 1;
    };
  }

  public final func RandomiseLowerImages() -> Void {
    let randomIdx: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_imagesLower) {
      randomIdx = RandRange(0, ArraySize(this.m_imagePresets));
      inkImageRef.SetTexturePart(this.m_imagesLower[i], this.m_imagePresets[randomIdx]);
      i += 1;
    };
  }

  public final func RandomiseImages(isWinning: Bool) -> Void {
    let randomIdx: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_imagesLower) {
      randomIdx = RandRange(0, ArraySize(this.m_imagePresets));
      inkImageRef.SetTexturePart(this.m_imagesUpper[i], this.m_imagePresets[randomIdx]);
      inkImageRef.SetTexturePart(this.m_imagesLower[i], this.m_imagePresets[randomIdx]);
      i += 1;
    };
    if isWinning {
      this.SetWinningRow();
    };
  }

  public final func SetWinningRow() -> Void {
    let randomIdx: Int32 = RandRange(0, ArraySize(this.m_imagePresets));
    inkImageRef.SetTexturePart(this.m_imagesUpper[this.m_winningRowIndex], this.m_imagePresets[randomIdx]);
    inkImageRef.SetTexturePart(this.m_imagesLower[this.m_winningRowIndex], this.m_imagePresets[randomIdx]);
  }
}
