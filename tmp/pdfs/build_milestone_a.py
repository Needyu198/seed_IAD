from pathlib import Path
import random
import re

from reportlab.lib.colors import Color, HexColor, white
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase.pdfmetrics import stringWidth
from reportlab.platypus import Paragraph
from reportlab.pdfgen import canvas


ROOT = Path('/Users/apple/Seed_IAD_project1')
OUT = ROOT / 'output' / 'pdf'
OUT.mkdir(parents=True, exist_ok=True)

BACKGROUND = ROOT / 'Seed_IAD_project1' / 'Assets.xcassets' / 'nature_background.imageset' / 'nature_background.png'
TREE = ROOT / 'Seed_IAD_project1' / 'Assets.xcassets' / 'perfect_tree.imageset' / 'perfect_tree.png'

ABSTRACT = """Seed Journey is a three-minute, offline SwiftUI experience that turns plant care into a small story about balance, consequence, and responsibility. The user begins with one seed, physically drags it into the earth, covers it with a sweeping gesture, and awakens it through touch. Six choices then determine how the plant develops: water, sunlight, and wind can be applied in different combinations, each producing visible feedback and a final tree shaped by those decisions.

The experience addresses a simple learning problem: environmental systems are often explained as lists of facts rather than relationships. Seed Journey makes those relationships tangible. Too little water creates a dry tree, excess water floods the roots, harsh sunlight burns the leaves, and missing wind leaves the plant fragile. Balanced care rewards the player with a flourishing pink tree, while other reasonable combinations still produce a healthy result. Replay encourages experimentation without punishment.

Seed Journey is a strong fit for WWDC because it uses Apple platform capabilities as part of the storytelling. SwiftUI powers responsive stacks, layered scenery, transitions, and spring animations. DragGesture transforms planting into direct manipulation, sensory feedback gives important moments physical weight, Dynamic Type and accessibility labels support more users, and the Swift Observation framework keeps the experience state clear and testable. All imagery and synthesized ambient audio live inside the app, so the complete journey works without Wi-Fi, accounts, analytics, or external services. The result is focused, playful, technically deliberate, and achievable within a short session for curious learners everywhere to enjoy."""


def word_count(text: str) -> int:
    return len(re.findall(r"\b[\w'-]+\b", text))


def draw_cover_image(c, path, x, y, width, height):
    image = ImageReader(str(path))
    iw, ih = image.getSize()
    scale = max(width / iw, height / ih)
    dw, dh = iw * scale, ih * scale
    c.saveState()
    clipping = c.beginPath()
    clipping.rect(x, y, width, height)
    c.clipPath(clipping, stroke=0, fill=0)
    c.drawImage(image, x + (width - dw) / 2, y + (height - dh) / 2, dw, dh, mask='auto')
    c.restoreState()


def proposal_pdf():
    assert word_count(ABSTRACT) == 250, f"Abstract is {word_count(ABSTRACT)} words, expected 250"
    path = OUT / 'Seed_Journey_Concept_Proposal.pdf'
    w, h = A4
    c = canvas.Canvas(str(path), pagesize=A4)
    draw_cover_image(c, BACKGROUND, 0, 0, w, h)
    c.setFillColor(Color(0.015, 0.08, 0.045, alpha=0.82))
    c.rect(0, 0, w, h, fill=1, stroke=0)

    c.setFillColor(HexColor('#C5F553'))
    c.roundRect(42, h - 75, 128, 25, 12, fill=1, stroke=0)
    c.setFillColor(HexColor('#12331C'))
    c.setFont('Helvetica-Bold', 9)
    c.drawCentredString(106, h - 66, 'WWDC STUDENT PROJECT')

    c.setFillColor(white)
    c.setFont('Helvetica-Bold', 34)
    c.drawString(42, h - 125, 'Seed Journey')
    c.setFont('Helvetica', 15)
    c.setFillColor(Color(1, 1, 1, alpha=0.82))
    c.drawString(44, h - 149, 'A three-minute story about care and consequence')

    panel_x, panel_y, panel_w, panel_h = 38, 95, 370, 560
    c.setFillColor(Color(0.02, 0.13, 0.07, alpha=0.88))
    c.roundRect(panel_x, panel_y, panel_w, panel_h, 22, fill=1, stroke=0)
    c.setStrokeColor(Color(1, 1, 1, alpha=0.18))
    c.roundRect(panel_x, panel_y, panel_w, panel_h, 22, fill=0, stroke=1)

    c.setFillColor(HexColor('#C5F553'))
    c.setFont('Helvetica-Bold', 11)
    c.drawString(62, 625, 'CONCEPT ABSTRACT  /  250 WORDS')

    style = ParagraphStyle(
        'abstract', fontName='Helvetica', fontSize=10.3, leading=14.6,
        textColor=white, alignment=TA_LEFT, spaceAfter=8
    )
    paragraph = Paragraph(ABSTRACT.replace('\n\n', '<br/><br/>'), style)
    paragraph.wrapOn(c, 322, 480)
    paragraph.drawOn(c, 62, 158)

    c.setFillColor(HexColor('#C5F553'))
    c.setFont('Helvetica-Bold', 10)
    c.drawString(62, 128, 'CORE LOOP')
    c.setFillColor(white)
    c.setFont('Helvetica', 9.5)
    c.drawString(62, 112, 'Plant  ->  Cover  ->  Care x6  ->  Grow  ->  Reflect  ->  Replay')

    c.drawImage(str(TREE), 400, 88, 184, 455, preserveAspectRatio=True, anchor='c', mask='auto')
    c.setFillColor(Color(0.77, 0.96, 0.32, alpha=0.12))
    c.circle(493, 300, 104, fill=1, stroke=0)
    c.drawImage(str(TREE), 400, 88, 184, 455, preserveAspectRatio=True, anchor='c', mask='auto')

    c.setFillColor(Color(1, 1, 1, alpha=0.68))
    c.setFont('Helvetica', 8)
    c.drawString(42, 42, 'Milestone A  •  Interactive Mockup  •  Native SwiftUI  •  100% Offline')
    c.drawRightString(w - 42, 42, 'SEED JOURNEY  /  01')
    c.save()
    return path


def jitter_line(c, x1, y1, x2, y2, width=1.2, color=HexColor('#183C27')):
    c.setStrokeColor(color)
    c.setLineWidth(width)
    for _ in range(2):
        j = lambda: random.uniform(-1.2, 1.2)
        c.line(x1 + j(), y1 + j(), x2 + j(), y2 + j())


def sketch_box(c, x, y, w, h, title, note, number, accent=HexColor('#C5F553')):
    c.setFillColor(Color(1, 1, 1, alpha=0.88))
    c.roundRect(x, y, w, h, 12, fill=1, stroke=0)
    random.seed(number * 117)
    c.setStrokeColor(HexColor('#183C27'))
    for inset in (0, 1.5):
        c.roundRect(x + inset + random.uniform(-1, 1), y + inset + random.uniform(-1, 1), w - inset * 2, h - inset * 2, 12, fill=0, stroke=1)
    c.setFillColor(accent)
    c.circle(x + 19, y + h - 19, 12, fill=1, stroke=0)
    c.setFillColor(HexColor('#14321D'))
    c.setFont('Helvetica-Bold', 9)
    c.drawCentredString(x + 19, y + h - 22, str(number))
    c.setFont('Helvetica-BoldOblique', 12)
    c.drawString(x + 38, y + h - 23, title)
    c.setFont('Helvetica-Oblique', 8.2)
    text = Paragraph(note, ParagraphStyle('note', fontName='Helvetica-Oblique', fontSize=8.2, leading=10, textColor=HexColor('#294C35')))
    text.wrapOn(c, w - 24, 35)
    text.drawOn(c, x + 12, y + 13)


def arrow(c, x1, y1, x2, y2):
    jitter_line(c, x1, y1, x2, y2, 1.4)
    angle = __import__('math').atan2(y2 - y1, x2 - x1)
    length = 8
    for delta in (2.55, -2.55):
        jitter_line(c, x2, y2, x2 + length * __import__('math').cos(angle + delta), y2 + length * __import__('math').sin(angle + delta), 1.4)


def wireframe_pdf():
    path = OUT / 'Seed_Journey_Hand_Drawn_Wireframe.pdf'
    w, h = landscape(A4)
    c = canvas.Canvas(str(path), pagesize=(w, h))
    c.setFillColor(HexColor('#F5F0DF'))
    c.rect(0, 0, w, h, fill=1, stroke=0)

    # Notebook grid and binding marks create a hand-drawn presentation style.
    c.setStrokeColor(Color(0.22, 0.55, 0.39, alpha=0.1))
    c.setLineWidth(0.4)
    for x in range(20, int(w), 20): c.line(x, 0, x, h)
    for y in range(20, int(h), 20): c.line(0, y, w, y)
    c.setFillColor(HexColor('#173A25'))
    c.setFont('Helvetica-BoldOblique', 25)
    c.drawString(38, h - 48, 'Seed Journey - hand-drawn experience map')
    c.setFont('Helvetica-Oblique', 10)
    c.setFillColor(HexColor('#466352'))
    c.drawString(40, h - 66, 'One continuous three-minute loop • arrows show the user path • care choices shape the ending')

    box_w, box_h = 137, 92
    xs = [38, 198, 358, 518, 678]
    top_y = 352
    sketch_box(c, xs[0], top_y, box_w, box_h, 'OPEN', 'Floating seed.<br/>Tap anywhere.', 0)
    sketch_box(c, xs[1], top_y, box_w, box_h, 'PLANT', 'Drag seed into<br/>the soil opening.', 1)
    sketch_box(c, xs[2], top_y, box_w, box_h, 'COVER', 'Swipe sideways<br/>across loose soil.', 2)
    sketch_box(c, xs[3], top_y, box_w, box_h, 'AWAKEN', 'Tap the glowing<br/>earth + feel haptic.', 3)
    sketch_box(c, xs[4], top_y, box_w, box_h, 'CARE', 'Choose water,<br/>sun, or wind.', 4)
    for i in range(4): arrow(c, xs[i] + box_w, top_y + box_h / 2, xs[i + 1] - 6, top_y + box_h / 2)

    # Care loop.
    care_y = 220
    choices = [('WATER', 'rain cloud', '#63B8FF'), ('SUN', 'warm light', '#FFD04A'), ('WIND', 'moving leaves', '#73D8B3')]
    for i, (name, note, color) in enumerate(choices):
        x = 520 + i * 100
        c.setFillColor(HexColor(color))
        c.circle(x + 34, care_y + 42, 30, fill=1, stroke=0)
        c.setFillColor(HexColor('#173A25'))
        c.setFont('Helvetica-BoldOblique', 9)
        c.drawCentredString(x + 34, care_y + 40, name)
        c.setFont('Helvetica-Oblique', 7.5)
        c.drawCentredString(x + 34, care_y + 25, note)
    arrow(c, 746, top_y, 746, care_y + 80)
    jitter_line(c, 554, care_y + 5, 754, care_y + 5, 1.2)
    arrow(c, 554, care_y + 5, 554, top_y - 5)
    c.setFont('Helvetica-BoldOblique', 9)
    c.drawString(578, care_y - 12, 'repeat until 6 care actions')

    grow_y = 82
    sketch_box(c, 358, grow_y, 170, 92, 'GROW', 'Seed -> sprout -> plant<br/>-> young tree -> mature tree', 5)
    sketch_box(c, 580, grow_y, 170, 92, 'RESULT', 'Outcome follows the<br/>care-balance priority.', 6)
    arrow(c, 688, care_y, 500, grow_y + 92)
    arrow(c, 528, grow_y + 46, 574, grow_y + 46)

    result_labels = [('FLOOD', '#67B8FF'), ('BURN', '#FF8068'), ('DRY', '#D59A55'), ('FRAGILE', '#B6B4A9'), ('PERFECT', '#F39BC4'), ('GOOD', '#8AD65C')]
    for i, (label, color) in enumerate(result_labels):
        x = 42 + i * 104
        c.setFillColor(HexColor(color))
        c.roundRect(x, 25, 86, 27, 9, fill=1, stroke=0)
        c.setFillColor(HexColor('#173A25'))
        c.setFont('Helvetica-BoldOblique', 7.5)
        c.drawCentredString(x + 43, 35, label)
    arrow(c, 665, grow_y, 665, 57)
    c.setFont('Helvetica-BoldOblique', 9)
    c.setFillColor(HexColor('#173A25'))
    c.drawRightString(w - 36, 31, 'REPLAY loops back to OPEN')

    c.setFillColor(Color(0.77, 0.96, 0.32, alpha=0.75))
    c.roundRect(38, 480, 244, 36, 14, fill=1, stroke=0)
    c.setFillColor(HexColor('#173A25'))
    c.setFont('Helvetica-BoldOblique', 10)
    c.drawCentredString(160, 494, 'DIRECT TOUCH -> CONSEQUENCE -> REFLECTION')
    c.save()
    return path


if __name__ == '__main__':
    outputs = [proposal_pdf(), wireframe_pdf()]
    for output in outputs:
        print(output)
