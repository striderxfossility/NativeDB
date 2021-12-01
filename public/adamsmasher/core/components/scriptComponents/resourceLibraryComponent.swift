
public class ResourceLibraryComponent extends ScriptableComponent {

  @attrib(category, "Effects Resources")
  private edit const let resources: array<FxResourceMapData>;

  public final const func GetResource(key: CName) -> FxResource {
    let resource: FxResource;
    let i: Int32 = 0;
    while i < ArraySize(this.resources) {
      if Equals(this.resources[i].key, key) {
        resource = this.resources[i].resource;
      } else {
        i += 1;
      };
    };
    return resource;
  }
}
