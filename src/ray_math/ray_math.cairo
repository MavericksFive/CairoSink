const RAY: u256 = 1000000000000000000000000000;
const HALF_RAY: u256 = 500000000000000000000000000;

trait IRayMath {
    fn ray_mul(a: u256, b: u256) -> u256;
    fn ray_div(a: u256, b: u256) -> u256;
}

impl RayMath of IRayMath {
    fn ray_mul(a: u256, b: u256) -> u256 {
        return (a * b + HALF_RAY) / RAY;
    }

    fn ray_div(a: u256, b: u256) -> u256 {
        (a * RAY + b / 2) / b
    }
}
