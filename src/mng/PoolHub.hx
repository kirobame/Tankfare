package mng;

using Extensions;

class PoolHub 
{
    static var obstaclePools : Array<Pool<Obstacle>>;
    static var bulletPools : Array<Pool<Bullet>>;

    static public function init()
    {
        obstaclePools =
        [
            new Pool<Obstacle>(new Obstacle(hxd.Res.wall.toObj(0xE3BD78)), 50)
        ];

        bulletPools = 
        [
            new Pool<Bullet>(new Bullet(hxd.Res.bullet.toObj(0xDB8E4F), 10, 2), 10)
        ];
    }

    static public function getObstaclePool(index : Int) { return obstaclePools[index]; }
    static public function getBulletPool(index : Int) { return bulletPools[index]; }
}