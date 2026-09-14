"""
NAI uygulama ikonunu üretir.
- app_icon.png: 1024x1024, koyu arka planlı, tam ikon (Play/legacy launcher için)
- app_icon_fg.png: 1024x1024, şeffaf arka planlı ön plan (adaptive icon foreground)
- splash.png: 512x512, sadece kıvılcım (splash ekranı için)

Stil: Gemini benzeri 4 köşeli "kıvılcım" (sparkle) formu, mor->mavi->camgöbeği
gradyan, koyu tema ile uyumlu.
"""
from PIL import Image, ImageDraw, ImageFilter
import math

SIZE = 1024


def lerp(a, b, t):
    return a + (b - a) * t


def lerp_color(c1, c2, t):
    return tuple(int(lerp(c1[i], c2[i], t)) for i in range(3))


def gradient_color(x, y, size):
    # Diagonal gradient: mor (üst-sol) -> mavi (orta) -> camgöbeği (alt-sağ)
    t = (x / size + y / size) / 2
    stops = [
        (0.0, (138, 92, 246)),   # mor
        (0.5, (79, 140, 255)),   # mavi
        (1.0, (56, 214, 209)),   # camgöbeği
    ]
    for i in range(len(stops) - 1):
        t0, c0 = stops[i]
        t1, c1 = stops[i + 1]
        if t0 <= t <= t1:
            local_t = (t - t0) / (t1 - t0) if t1 > t0 else 0
            return lerp_color(c0, c1, local_t)
    return stops[-1][1]


def make_gradient(size):
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            px[x, y] = gradient_color(x, y, size)
    return img


def sparkle_path(cx, cy, r_outer, r_inner):
    """4 köşeli kıvılcım (Gemini benzeri) yıldız yolu döndürür."""
    pts = []
    n_points = 4
    for i in range(n_points * 2):
        angle = math.pi / n_points * i - math.pi / 2
        r = r_outer if i % 2 == 0 else r_inner
        # Kıvılcım formunu daha keskin/konkav yapmak için üssel eğri uygula
        x = cx + r * math.cos(angle)
        y = cy + r * math.sin(angle)
        pts.append((x, y))
    return pts


def _quad_bezier(p0, p1, p2, steps):
    pts = []
    for i in range(steps + 1):
        t = i / steps
        mt = 1 - t
        x = mt * mt * p0[0] + 2 * mt * t * p1[0] + t * t * p2[0]
        y = mt * mt * p0[1] + 2 * mt * t * p1[1] + t * t * p2[1]
        pts.append((x, y))
    return pts


def make_sparkle_mask(size, scale=0.62, waist=0.16):
    """Klasik 4 uçlu 'kıvılcım' (sparkle) formu: 4 sivri uç + aralarında
    içbükey eğriler. Uçlar arasındaki eğri, merkeze yakın bir kontrol
    noktasından geçen quadratic bezier ile çizilir (Gemini logosuna benzer)."""
    ss = 4  # supersample ile pürüzsüzleştirme
    big = size * ss
    mask = Image.new("L", (big, big), 0)
    d = ImageDraw.Draw(mask)
    cx = cy = big / 2
    r_outer = big / 2 * scale
    r_ctrl = r_outer * waist

    tip_angles = [-math.pi / 2, 0, math.pi / 2, math.pi]  # üst, sağ, alt, sol
    ctrl_angles = [-math.pi / 4, math.pi / 4, 3 * math.pi / 4, -3 * math.pi / 4]

    tips = [(cx + r_outer * math.cos(a), cy + r_outer * math.sin(a)) for a in tip_angles]
    ctrls = [(cx + r_ctrl * math.cos(a), cy + r_ctrl * math.sin(a)) for a in ctrl_angles]

    pts = []
    n = len(tips)
    for i in range(n):
        p0 = tips[i]
        p1 = ctrls[i]
        p2 = tips[(i + 1) % n]
        pts.extend(_quad_bezier(p0, p1, p2, 60)[:-1])

    d.polygon(pts, fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(big // 300))
    mask = mask.resize((size, size), Image.LANCZOS)
    return mask


def build_icon(with_background: bool, out_path: str):
    grad = make_gradient(SIZE)
    sparkle_mask = make_sparkle_mask(SIZE, scale=0.60 if with_background else 0.86)

    if with_background:
        bg = Image.new("RGB", (SIZE, SIZE), (11, 15, 25))  # #0B0F19 koyu zemin
        # Hafif köşeli kare (Play Store legacy ikon için köşeleri biraz yuvarlat)
        canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        canvas.paste(bg, (0, 0))
    else:
        canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

    sparkle_rgba = Image.new("RGBA", (SIZE, SIZE))
    sparkle_rgba.paste(grad, (0, 0))
    sparkle_rgba.putalpha(sparkle_mask)

    # Hafif dış parlama (glow)
    glow = sparkle_rgba.split()[3].filter(ImageFilter.GaussianBlur(SIZE // 28))
    glow_layer = Image.new("RGBA", (SIZE, SIZE), (99, 140, 255, 0))
    glow_layer.putalpha(glow.point(lambda a: int(a * 0.55)))

    canvas = Image.alpha_composite(canvas, glow_layer)
    canvas = Image.alpha_composite(canvas, sparkle_rgba)

    canvas.save(out_path)


def build_splash(out_path: str, size=512):
    grad = make_gradient(size)
    mask = make_sparkle_mask(size, scale=0.72)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sparkle_rgba = Image.new("RGBA", (size, size))
    sparkle_rgba.paste(grad, (0, 0))
    sparkle_rgba.putalpha(mask)
    canvas = Image.alpha_composite(canvas, sparkle_rgba)
    canvas.save(out_path)


if __name__ == "__main__":
    import os
    os.makedirs("assets/icon", exist_ok=True)
    build_icon(with_background=True, out_path="assets/icon/app_icon.png")
    build_icon(with_background=False, out_path="assets/icon/app_icon_fg.png")
    build_splash("assets/icon/splash.png")
    print("Icons generated.")
