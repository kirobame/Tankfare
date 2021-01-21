class Observable extends h3d.scene.Object
{
    var observers : List<ObjectCallbackKind -> Void>;

    public function new ()
    {
        super();
        observers = new List<ObjectCallbackKind -> Void>();
    }

    public function subscribe(delegate : ObjectCallbackKind -> Void)
    {
        observers.add(delegate);
    }
    public function unsubscribe(delegate : ObjectCallbackKind -> Void)
    {
        observers.remove(delegate);
    }

    private function sendCallback(kind : ObjectCallbackKind)
    {
        for (delegate in observers) delegate(kind);
    }
}

enum ObjectCallbackKind
{
    OnBinned;
}