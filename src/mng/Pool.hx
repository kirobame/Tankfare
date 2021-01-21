package mng;

class Pool<T>
{
    var template : h3d.scene.Object;
    var queue : List<Poolable<T>>;

    public function new (template : T, initialSize : Int)
    {
        this.template = cast template;

        this.template.visible = false;
        this.template.ignoreBounds = true;
        this.template.ignoreCollide = true;

        queue = new List<Poolable<T>>();
        for (i in 0...initialSize) stockFromTemplate();
    }

    public function take()
    {
        if (queue.length == 0) stockFromTemplate();

        var poolable = queue.pop();
        poolable.init();

        return poolable;
    }
    public function request(amount : Int)
    {
        var difference = amount - queue.length;
        for (i in 0...difference) stockFromTemplate();

        var results = new Array<Poolable<T>>();
        results.resize(amount);

        for (i in 0...amount) 
        {
            var poolable = queue.pop();
            poolable.init();

            results[i] = poolable;
        }

        return results;
    }
    public function stock(poolable : Poolable<T>)
    {
        queue.add(poolable);
    }

    private function stockFromTemplate()
    {
        var instance = template.clone();
        var poolable = new Poolable<T>(this, instance);

        queue.add(poolable);
    }
}