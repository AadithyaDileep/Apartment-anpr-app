import 'package:flutter/material.dart';
import 'theme.dart';

void toast(BuildContext c, String m) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));
}

/// Gradient-filled text (white -> light blue -> blue), the same look as the
/// splash screen. Use it for titles and headings.
class GradText extends StatelessWidget {
  const GradText(
    this.text, {
    super.key,
    this.style,
    this.colors = const [Colors.white, cAccent, cGold],
    this.glow = false,
    this.align,
    this.maxLines,
    this.overflow,
  });
  final String text;
  final TextStyle? style;
  final List<Color> colors;
  final bool glow;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => LinearGradient(colors: colors).createShader(r),
        child: Text(
          text,
          textAlign: align,
          maxLines: maxLines,
          overflow: overflow,
          style: (style ?? const TextStyle()).copyWith(
            color: Colors.white,
            shadows: glow ? [Shadow(color: cGold.withValues(alpha: .5), blurRadius: 14)] : null,
          ),
        ),
      );
}

/// App name (text only, no symbol), gradient like the splash screen.
class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) =>
      GradText('SMARTGATE', style: serifStyle(30).copyWith(letterSpacing: 7), glow: true);
}

class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.color = cGold, this.size = 44});
  final IconData icon;
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color.withValues(alpha: .15), borderRadius: BorderRadius.circular(size * .3)),
        child: Icon(icon, color: color, size: size * .5),
      );
}

class Pill extends StatelessWidget {
  const Pill(this.text, this.color, {super.key});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: .5)),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: cCard,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: padding,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: cLine)),
              child: child,
            ),
          ),
        ),
      );
}

class Tile extends StatelessWidget {
  const Tile(this.icon, this.title, this.subtitle, {super.key, this.color = cGold, this.trailing, this.onTap, this.iconSize = 40});
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double iconSize;
  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          IconBadge(icon, color: color, size: iconSize),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 15)),
              if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(color: cAccent, fontSize: 12.5)),
            ]),
          ),
          if (trailing != null) trailing! else if (onTap != null) const Icon(Icons.chevron_right, color: cAccent),
        ]),
      );
}

class Empty extends StatelessWidget {
  const Empty(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text(text, textAlign: TextAlign.center, style: muted)),
      );
}

class AppField extends StatefulWidget {
  const AppField(this.label, {super.key, this.ctrl, this.keyboard, this.obscure = false, this.caps = false});
  final String label;
  final TextEditingController? ctrl;
  final TextInputType? keyboard;
  final bool obscure, caps;
  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  late bool _hide = widget.obscure;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          controller: widget.ctrl,
          keyboardType: widget.keyboard,
          obscureText: _hide,
          textCapitalization: widget.caps ? TextCapitalization.characters : TextCapitalization.none,
          decoration: InputDecoration(
            labelText: widget.label,
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(_hide ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: cMute),
                    onPressed: () => setState(() => _hide = !_hide),
                  )
                : null,
          ),
        ),
      );
}

class GoldBtn extends StatelessWidget {
  const GoldBtn(this.text, this.onTap, {super.key, this.icon, this.outline = false, this.wide = false, this.color = cGold});
  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final bool outline, wide;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = Text(text, style: const TextStyle(fontWeight: FontWeight.w600));
    const shape = StadiumBorder();
    const pad = EdgeInsets.symmetric(vertical: 14, horizontal: 24);
    final Widget btn;
    if (outline) {
      final st = OutlinedButton.styleFrom(foregroundColor: color, side: BorderSide(color: color), shape: shape, padding: pad);
      btn = icon == null
          ? OutlinedButton(onPressed: onTap, style: st, child: label)
          : OutlinedButton.icon(onPressed: onTap, style: st, icon: Icon(icon, size: 18), label: label);
    } else {
      final st = FilledButton.styleFrom(
          backgroundColor: color, foregroundColor: color == cRed ? Colors.white : Colors.black, shape: shape, padding: pad);
      btn = icon == null
          ? FilledButton(onPressed: onTap, style: st, child: label)
          : FilledButton.icon(onPressed: onTap, style: st, icon: Icon(icon, size: 18), label: label);
    }
    return wide ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// Pushed page with an app bar and a scrolling list.
class SubPage extends StatelessWidget {
  const SubPage(this.title, this.children, {super.key});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: GradText(title, style: serifStyle(20), glow: true)),
        body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: children)),
      );
}

/// Bottom-tab page with an eyebrow label and a big gradient title.
class TabPage extends StatelessWidget {
  const TabPage(this.eyebrow, this.title, this.children, {super.key, this.trailing});
  final String eyebrow, title;
  final List<Widget> children;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(eyebrow.toUpperCase(), style: const TextStyle(color: cAccent, letterSpacing: 2.5, fontSize: 10)),
                GradText(title, style: serifStyle(30), glow: true),
              ]),
            ),
            if (trailing != null) trailing!,
          ]),
          const SizedBox(height: 18),
          ...children,
        ]),
      );
}