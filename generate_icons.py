import os
from PIL import Image, ImageDraw, ImageFont
import math

def create_tar_tv_icon(size):
    # Criar imagem com fundo transparente
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Cores TarSystem
    blue_primary = (43, 92, 176)  # #2B5CB0
    blue_dark = (30, 64, 128)     # #1E4080
    
    # Criar gradiente azul (simulado)
    for y in range(size):
        ratio = y / size
        r = int(blue_primary[0] * (1 - ratio) + blue_dark[0] * ratio)
        g = int(blue_primary[1] * (1 - ratio) + blue_dark[1] * ratio)
        b = int(blue_primary[2] * (1 - ratio) + blue_dark[2] * ratio)
        
        draw.rectangle([(0, y), (size, y + 1)], fill=(r, g, b, 255))
    
    # Arredondar bordas
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    radius = int(size * 0.15)  # 15% border radius
    mask_draw.rounded_rectangle([(0, 0), (size, size)], radius=radius, fill=255)
    
    # Aplicar máscara
    output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    output.paste(img, (0, 0))
    output.putalpha(mask)
    
    # Desenhar símbolo # (hashtag)
    hash_color = (255, 255, 255, 255)  # Branco
    line_width = max(1, int(size * 0.08))  # 8% da largura
    center = size // 2
    hash_size = int(size * 0.4)  # 40% do tamanho
    line_offset = int(hash_size * 0.3)
    
    draw = ImageDraw.Draw(output)
    
    # Linhas verticais do #
    draw.line([
        (center - line_offset, center - hash_size // 2),
        (center - line_offset, center + hash_size // 2)
    ], fill=hash_color, width=line_width)
    
    draw.line([
        (center + line_offset, center - hash_size // 2),
        (center + line_offset, center + hash_size // 2)
    ], fill=hash_color, width=line_width)
    
    # Linhas horizontais do #
    draw.line([
        (center - hash_size // 2, center - line_offset),
        (center + hash_size // 2, center - line_offset)
    ], fill=hash_color, width=line_width)
    
    draw.line([
        (center - hash_size // 2, center + line_offset),
        (center + hash_size // 2, center + line_offset)
    ], fill=hash_color, width=line_width)
    
    # Desenhar mini TV no canto inferior direito
    tv_size = int(size * 0.15)
    tv_x = size - tv_size - int(size * 0.1)
    tv_y = size - tv_size - int(size * 0.1)
    
    # Corpo da TV
    draw.rounded_rectangle([
        (tv_x, tv_y),
        (tv_x + tv_size, tv_y + int(tv_size * 0.7))
    ], radius=int(tv_size * 0.1), fill=(255, 255, 255, 200))
    
    # Antenas da TV
    antenna_width = max(1, int(size * 0.015))
    draw.line([
        (tv_x + int(tv_size * 0.3), tv_y),
        (tv_x + int(tv_size * 0.2), tv_y - int(tv_size * 0.3))
    ], fill=(255, 255, 255, 200), width=antenna_width)
    
    draw.line([
        (tv_x + int(tv_size * 0.7), tv_y),
        (tv_x + int(tv_size * 0.8), tv_y - int(tv_size * 0.3))
    ], fill=(255, 255, 255, 200), width=antenna_width)
    
    return output

def generate_all_icons():
    # Tamanhos necessários para Android
    android_sizes = [
        (48, 'mipmap-mdpi'),
        (72, 'mipmap-hdpi'),
        (96, 'mipmap-xhdpi'),
        (144, 'mipmap-xxhdpi'),
        (192, 'mipmap-xxxhdpi'),
    ]
    
    # Tamanhos para web
    web_sizes = [192, 512]
    
    base_path = 'C:/FlutterProjects/TarTV'
    
    # Gerar ícones Android
    for size, folder in android_sizes:
        icon = create_tar_tv_icon(size)
        android_path = f'{base_path}/android/app/src/main/res/{folder}'
        os.makedirs(android_path, exist_ok=True)
        icon.save(f'{android_path}/ic_launcher.png', 'PNG')
        print(f'Ícone Android gerado: {folder}/ic_launcher.png ({size}x{size})')
    
    # Gerar ícones Web
    web_path = f'{base_path}/web/icons'
    os.makedirs(web_path, exist_ok=True)
    
    for size in web_sizes:
        icon = create_tar_tv_icon(size)
        icon.save(f'{web_path}/Icon-{size}.png', 'PNG')
        icon.save(f'{web_path}/Icon-maskable-{size}.png', 'PNG')
        print(f'Ícones Web gerados: Icon-{size}.png e Icon-maskable-{size}.png')
    
    # Gerar favicon
    favicon = create_tar_tv_icon(32)
    favicon.save(f'{base_path}/web/favicon.png', 'PNG')
    print('Favicon gerado: favicon.png')

if __name__ == '__main__':
    try:
        generate_all_icons()
        print('\n✅ Todos os ícones #TarTV foram gerados com sucesso!')
        print('🔄 Execute "flutter clean" e "flutter build apk" para aplicar os novos ícones.')
    except Exception as e:
        print(f'❌ Erro ao gerar ícones: {e}')
        print('💡 Certifique-se de ter o Pillow instalado: pip install Pillow')
