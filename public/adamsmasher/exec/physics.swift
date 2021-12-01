
public static exec func Pvd(server: String) -> Void {
  PvdClientConnect(server);
}

public static exec func PvdDump(filePath: String) -> Void {
  PvdFileDumpConnect(filePath);
}
