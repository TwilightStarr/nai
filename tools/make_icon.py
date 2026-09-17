"""
NAI uygulama ikonunu üretir.
- app_icon.png: 1024x1024, koyu arka planlı, tam ikon (Play/legacy launcher için)
- app_icon_fg.png: 1024x1024, şeffaf arka planlı ön plan (adaptive icon foreground)
- splash.png: 512x512, sadece amblem (splash ekranı için)

Stil: Okulun adından ("Nevzat") gelen özgün bir "N" monogramı; iki dikey
gövde + bağlayıcı diyagonalden oluşan modern amblem, mor->mavi->camgöbeği
gradyan, koyu tema ile uyumlu. (Önceki sürümdeki 4 uçlu "kıvılcım" şekli
Google Gemini ikonuna çok benziyordu; marka karışıklığını önlemek için
özgün bir monogramla değiştirildi.)
"""
from PIL import Image, ImageDraw, ImageFilter, ImageChops
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


def _perp_offset(p_from, p_to, half_thickness):
    """p_from->p_to doğrultusuna dik birim vektörü half_thickness ile ölçekler."""
    dx = p_to[0] - p_from[0]
    dy = p_to[1] - p_from[1]
    length = math.hypot(dx, dy) or 1
    px, py = -dy / length, dx / length
    return px * half_thickness, py * half_thickness


def make_n_mark_mask(size, scale=0.62, bar_ratio=0.30):
    """Özgün 'N' monogramı: iki dikey (yuvarlak köşeli) gövde + onları
    birleştiren diyagonal kesit. Üç parça da aynı gradyanla dolduğundan
    kesişim yerlerinde dikiş görünmez, tek parça bir harf gibi görünür."""
    ss = 4  # supersample ile pürüzsüzleştirme
    big = size * ss
    mask = Image.new("L", (big, big), 0)
    d = ImageDraw.Draw(mask)

    box_w = big * scale * 0.82
    box_h = big * scale
    x0 = (big - box_w) / 2
    y0 = (big - box_h) / 2
    bar_w = box_w * bar_ratio
    radius = bar_w * 0.30

    # Sol gövde
    d.rounded_rectangle(
        [x0, y0, x0 + bar_w, y0 + box_h], radius=radius, fill=255
    )
    # Sağ gövde
    d.rounded_rectangle(
        [x0 + box_w - bar_w, y0, x0 + box_w, y0 + box_h], radius=radius, fill=255
    )
    # Diyagonal (sol gövdenin tepesinden sağ gövdenin tabanına)
    top = (x0 + bar_w / 2, y0)
    bottom = (x0 + box_w - bar_w / 2, y0 + box_h)
    ox, oy = _perp_offset(top, bottom, bar_w * 0.94 / 2)
    diag_pts = [
        (top[0] + ox, top[1] + oy),
        (top[0] - ox, top[1] - oy),
        (bottom[0] - ox, bottom[1] - oy),
        (bottom[0] + ox, bottom[1] + oy),
    ]
    d.polygon(diag_pts, fill=255)

    # Diyagonalin döndürülmüş köşeleri gövde kutusunun az dışına taşabilir;
    # harfin dikdörtgen sınırıyla kesişimini alarak temiz bir kenar elde et.
    clip = Image.new("L", (big, big), 0)
    ImageDraw.Draw(clip).rectangle([x0, y0, x0 + box_w, y0 + box_h], fill=255)
    mask = ImageChops.multiply(mask, clip)

    mask = mask.filter(ImageFilter.GaussianBlur(big // 300))
    mask = mask.resize((size, size), Image.LANCZOS)
    return mask


def build_icon(with_background: bool, out_path: str):
    grad = make_gradient(SIZE)
    sparkle_mask = make_n_mark_mask(SIZE, scale=0.46 if with_background else 0.62)

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
    mask = make_n_mark_mask(size, scale=0.60)
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
