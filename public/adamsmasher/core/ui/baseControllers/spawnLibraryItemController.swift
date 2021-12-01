
public class SpawnLibraryItemController extends inkLogicController {

  protected edit let m_libraryID: CName;

  protected cb func OnInitialize() -> Bool {
    this.SpawnFromLocal(this.GetRootWidget(), this.m_libraryID);
  }
}
