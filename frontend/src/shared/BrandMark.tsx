// The Kandypack logo mark: the letter K drawn as the rail map, with Kandy as the amber hub.
// The lines take the text colour of the tile it sits in. The rings are filled with the tile's
// background, which each tile class passes in the --mark-ground CSS variable.
export default function BrandMark({ size = 22 }: { size?: number }) {
  const ground = { fill: 'var(--mark-ground, #fff)' };
  return (
    <svg viewBox="0 0 96 96" width={size} height={size} aria-hidden="true">
      <g fill="none" stroke="currentColor" strokeWidth={10} strokeLinecap="round" strokeLinejoin="round">
        <path d="M32 16V80" />
        <path d="M32 50L64 18" />
        <path d="M32 50L64 82" />
      </g>
      <circle cx={64} cy={18} r={6.5} stroke="currentColor" strokeWidth={4} style={ground} />
      <circle cx={64} cy={82} r={6.5} stroke="currentColor" strokeWidth={4} style={ground} />
      <circle cx={32} cy={50} r={11} fill="#e3a02c" strokeWidth={4} style={{ stroke: 'var(--mark-ground, #fff)' }} />
    </svg>
  );
}
