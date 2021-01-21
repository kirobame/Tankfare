package mng;

class Poolable<T> extends h3d.scene.Object
{
    var source : Pool<T>;
    var target : Observable;

    public function new(source : Pool<T>, target : Observable)
    {
        super();

        setPosition(0,0,0);

        this.source = source;
        this.target = target;

        addChild(target);
        target.subscribe(onTargetCallback);
    }

    public function getValue()
    {
        var castedValue: T = cast target;
        return castedValue;
    }

    public function init()
    {
        setActive(true);
    }
    public function end()
    {
        remove();

        setActive(false);
        source.stock(this);
    }

    private function setActive(state : Bool)
    {
        visible = state;
        target.visible = state;

        ignoreBounds = !state;
        target.ignoreBounds = !state;

        ignoreCollide = !state;
        target.ignoreCollide = !state;
    }

    function onTargetCallback(kind : Observable.ObjectCallbackKind)
    {
        switch(kind)
        {
            case Observable.ObjectCallbackKind.OnBinned: end();
            case _:
        }
    }
}