
public class CustomAnimationsHudGameController extends inkHUDGameController {

  @attrib(category, "Animations")
  protected inline edit let m_customAnimations: ref<WidgetAnimationManager>;

  @attrib(category, "Animations")
  protected edit let m_onSpawnAnimations: array<CName>;

  @attrib(category, "Library")
  protected edit let m_defaultLibraryItemName: CName;

  @attrib(category, "Library")
  @default(CustomAnimationsHudGameController, inkEAnchor.Fill)
  protected edit let m_defaultLibraryItemAnchor: inkEAnchor;

  protected let m_spawnedLibrararyItem: wref<inkWidget>;

  protected let m_curentLibraryItemName: CName;

  protected let m_currentLibraryItemAnchor: inkEAnchor;

  protected let m_root: wref<inkCompoundWidget>;

  protected let m_isInitialized: Bool;

  private let m_ownerID: EntityID;

  protected cb func OnInitialize() -> Bool {
    this.m_ownerID = this.GetOwnerEntity().GetEntityID();
    this.m_root = this.GetRootWidget() as inkCompoundWidget;
    if !this.ResolveLibraryItemSpawn(this.m_defaultLibraryItemName, this.m_defaultLibraryItemAnchor, true) {
      this.PlayOnSpawnAnimations();
    };
    this.m_isInitialized = true;
  }

  protected cb func OnCustomUIAnimationEvent(evt: ref<CustomUIAnimationEvent>) -> Bool {
    if this.m_ownerID != evt.ownerID {
      return false;
    };
    if this.m_customAnimations != null {
      this.m_customAnimations.UpdateAnimationsList(evt.animationName, evt.animOptionsOverride);
      this.ResolveLibraryItemSpawn(evt.libraryItemName, evt.libraryItemAnchor, false, evt.forceRespawnLibraryItem);
      this.PlayAnimation(evt.animationName, evt.playbackOption);
    };
  }

  protected final func PlayAnimation(animationName: CName, playbackOption: EInkAnimationPlaybackOption) -> Void {
    if this.m_customAnimations != null {
      this.m_customAnimations.TriggerAnimationByName(this, animationName, playbackOption, this.m_spawnedLibrararyItem);
    };
  }

  private final func PlayOnSpawnAnimations() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_onSpawnAnimations) {
      this.PlayAnimation(this.m_onSpawnAnimations[i], EInkAnimationPlaybackOption.PLAY);
      i += 1;
    };
  }

  private final func ResolveLibraryItemSpawn(itemName: CName, anchor: inkEAnchor, opt async: Bool, opt forceRespawnLibraryItem: Bool) -> Bool {
    if !IsDefined(this.m_root) {
      return false;
    };
    if !IsNameValid(itemName) {
      return false;
    };
    if IsDefined(this.m_spawnedLibrararyItem) && Equals(itemName, this.m_curentLibraryItemName) && Equals(anchor, this.m_currentLibraryItemAnchor) && !forceRespawnLibraryItem {
      return false;
    };
    if !this.HasLocalLibrary(itemName) {
      return false;
    };
    if IsDefined(this.m_spawnedLibrararyItem) {
      this.m_root.RemoveChild(this.m_spawnedLibrararyItem);
      this.m_customAnimations.CleanAllAnimationsChachedData();
    };
    if async {
      this.AsyncSpawnFromLocal(this.m_root, itemName, this, n"OnInitialSpawnLibrararyItem");
      this.m_curentLibraryItemName = itemName;
      this.m_currentLibraryItemAnchor = anchor;
    } else {
      this.m_spawnedLibrararyItem = this.SpawnFromLocal(this.m_root, itemName);
      this.m_spawnedLibrararyItem.SetAnchor(anchor);
      this.m_curentLibraryItemName = itemName;
      this.m_currentLibraryItemAnchor = anchor;
    };
    return true;
  }

  protected cb func OnInitialSpawnLibrararyItem(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    this.m_spawnedLibrararyItem = widget;
    this.m_spawnedLibrararyItem.SetAnchor(this.m_currentLibraryItemAnchor);
    this.PlayOnSpawnAnimations();
  }
}
