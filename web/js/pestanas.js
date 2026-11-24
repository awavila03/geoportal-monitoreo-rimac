/* Pestañas accesibles (patrón WAI-ARIA Tabs, activación automática):
 * role=tablist/tab/tabpanel, aria-selected, foco itinerante, ←/→/↑/↓, Inicio, Fin. */

export function crearPestanas(tablist, alCambiar = () => {}) {
  const tabs = [...tablist.querySelectorAll('[role="tab"]')];

  function activar(id, { enfocar = false } = {}) {
    for (const t of tabs) {
      const activa = t.id === id;
      t.setAttribute("aria-selected", String(activa));
      t.tabIndex = activa ? 0 : -1;
      document.getElementById(t.getAttribute("aria-controls")).hidden = !activa;
      if (activa && enfocar) t.focus();
    }
    alCambiar(id);
  }

  tablist.addEventListener("click", (e) => {
    const t = e.target.closest('[role="tab"]');
    if (t) activar(t.id);
  });

  tablist.addEventListener("keydown", (e) => {
    const i = tabs.indexOf(document.activeElement);
    if (i < 0) return;
    let j = null;
    if (e.key === "ArrowRight" || e.key === "ArrowDown") j = (i + 1) % tabs.length;
    else if (e.key === "ArrowLeft" || e.key === "ArrowUp") j = (i - 1 + tabs.length) % tabs.length;
    else if (e.key === "Home") j = 0;
    else if (e.key === "End") j = tabs.length - 1;
    if (j === null) return;
    e.preventDefault();
    activar(tabs[j].id, { enfocar: true });
  });

  return { activar, activa: () => tabs.find((t) => t.getAttribute("aria-selected") === "true").id };
}
