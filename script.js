const navToggle = document.querySelector('.nav-toggle');
const siteNav = document.querySelector('.site-nav');
const navLinks = [...document.querySelectorAll('.nav-link')];
const sections = [...document.querySelectorAll('main .section')];

if (navToggle && siteNav) {
  navToggle.addEventListener('click', () => {
    const isOpen = siteNav.classList.toggle('open');
    navToggle.setAttribute('aria-expanded', String(isOpen));
  });
}

// Section ids that actually have a nav tab on this page.
const navTargets = new Set(
  navLinks
    .map((link) => link.getAttribute('href'))
    .filter((href) => href?.startsWith('#'))
    .map((href) => href.slice(1)),
);

const setActiveLink = (id) => {
  navLinks.forEach((link) => {
    const active = link.getAttribute('href') === `#${id}`;
    link.classList.toggle('active', active);
  });
};

// A thin trigger line across the middle of the viewport: whichever section
// crosses it is the active one. Using a ratio threshold instead would fail on
// tall sections, which can never fill enough of the observed band to qualify.
const observer = new IntersectionObserver(
  (entries) => {
    const crossing = entries
      .filter((entry) => entry.isIntersecting && navTargets.has(entry.target.id))
      .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);

    // Nothing tabbed is on the line (e.g. the download CTA) — keep the
    // current highlight rather than clearing it.
    if (crossing.length) {
      setActiveLink(crossing[0].target.id);
    }
  },
  {
    rootMargin: '-45% 0px -50% 0px',
    threshold: 0,
  },
);

sections.forEach((section) => observer.observe(section));

navLinks.forEach((link) => {
  link.addEventListener('click', () => {
    siteNav?.classList.remove('open');
    navToggle?.setAttribute('aria-expanded', 'false');
  });
});
