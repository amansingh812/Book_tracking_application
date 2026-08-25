/* @ds-bundle: {"format":3,"namespace":"SwaromDesignSystem_524c92","components":[{"name":"Home","sourcePath":"reference/swarom_page.tsx"}],"sourceHashes":{"reference/swarom_page.tsx":"97e53d7d2513","reference/swarom_tailwind.config.ts":"8e7a4eecdd50","ui_kits/website/App.jsx":"8744a54af8b0","ui_kits/website/BagDrawer.jsx":"45c5acdc0e7a","ui_kits/website/Footer.jsx":"483505c8787b","ui_kits/website/Header.jsx":"39893e78a65c","ui_kits/website/Home.jsx":"3055184a0308","ui_kits/website/ProductDetail.jsx":"93120ad2ba31","ui_kits/website/Shop.jsx":"d78107c84a0f","ui_kits/website/Story.jsx":"b8ee24f49324"},"inlinedExternals":[],"unexposedExports":[{"name":"config","sourcePath":"reference/swarom_tailwind.config.ts"}]} */

(() => {

const __ds_ns = (window.SwaromDesignSystem_524c92 = window.SwaromDesignSystem_524c92 || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// reference/swarom_page.tsx
try { (() => {
"use client";

const {
  useState,
  FormEvent
} = React;
function Home() {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState("idle");
  const [message, setMessage] = useState("");
  async function handleSubmit(e) {
    e.preventDefault();
    if (!email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
      setStatus("error");
      setMessage("Please enter a valid email address.");
      return;
    }
    setStatus("loading");
    // No backend yet — we store locally so users get a friendly response.
    // We'll wire this to a real list (Klaviyo / Sheets / Resend) at launch.
    try {
      const existing = JSON.parse(localStorage.getItem("swarom_waitlist") || "[]");
      if (!existing.includes(email)) existing.push(email);
      localStorage.setItem("swarom_waitlist", JSON.stringify(existing));
      setStatus("ok");
      setMessage("You're on the list. We'll be in touch when we open doors.");
      setEmail("");
    } catch {
      setStatus("error");
      setMessage("Something went wrong. Please try again.");
    }
  }
  return /*#__PURE__*/React.createElement("main", {
    className: "relative min-h-screen w-full overflow-hidden"
  }, /*#__PURE__*/React.createElement("div", {
    "aria-hidden": true,
    className: "pointer-events-none absolute -top-40 -right-40 h-96 w-96 rounded-full bg-gradient-to-br from-silver-light to-cream opacity-60 blur-3xl float"
  }), /*#__PURE__*/React.createElement("div", {
    "aria-hidden": true,
    className: "pointer-events-none absolute -bottom-40 -left-40 h-96 w-96 rounded-full bg-gradient-to-tr from-gold/20 to-cream opacity-50 blur-3xl float",
    style: {
      animationDelay: "2s"
    }
  }), /*#__PURE__*/React.createElement("div", {
    className: "relative z-10 mx-auto flex min-h-screen max-w-2xl flex-col px-6 py-10 sm:px-8 sm:py-14"
  }, /*#__PURE__*/React.createElement("header", {
    className: "flex items-center justify-between text-[11px] uppercase tracking-widest text-charcoal/60"
  }, /*#__PURE__*/React.createElement("span", null, "Swarom"), /*#__PURE__*/React.createElement("span", null, "Bengaluru \xB7 Est. 2026")), /*#__PURE__*/React.createElement("section", {
    className: "flex flex-1 flex-col items-center justify-center text-center"
  }, /*#__PURE__*/React.createElement("div", {
    className: "mb-10 flex items-center gap-3 text-[10px] uppercase tracking-widest text-charcoal/50"
  }, /*#__PURE__*/React.createElement("span", {
    className: "h-px w-8 bg-charcoal/30"
  }), /*#__PURE__*/React.createElement("span", null, "Coming Soon"), /*#__PURE__*/React.createElement("span", {
    className: "h-px w-8 bg-charcoal/30"
  })), /*#__PURE__*/React.createElement("h1", {
    className: "font-serif text-6xl font-medium leading-none tracking-tight text-charcoal sm:text-7xl md:text-8xl"
  }, "Swarom"), /*#__PURE__*/React.createElement("div", {
    className: "mt-4 h-px w-24 bg-gradient-to-r from-transparent via-gold to-transparent shimmer"
  }), /*#__PURE__*/React.createElement("p", {
    className: "mt-8 max-w-md font-serif text-xl italic text-charcoal/80 sm:text-2xl"
  }, "Your story, told in silver."), /*#__PURE__*/React.createElement("p", {
    className: "mt-5 max-w-md text-sm leading-relaxed text-charcoal/65 sm:text-base"
  }, "Personalized 925 sterling silver jewellery, handcrafted in Bengaluru. Made to order. Made to last."), /*#__PURE__*/React.createElement("form", {
    onSubmit: handleSubmit,
    className: "mt-10 flex w-full max-w-md flex-col gap-2 sm:flex-row"
  }, /*#__PURE__*/React.createElement("input", {
    type: "email",
    required: true,
    placeholder: "your@email.com",
    value: email,
    onChange: e => setEmail(e.target.value),
    disabled: status === "loading",
    className: "flex-1 rounded-full border border-charcoal/15 bg-cream-50 px-5 py-3 text-sm text-charcoal placeholder:text-charcoal/40 focus:border-charcoal/40 focus:outline-none focus:ring-0 disabled:opacity-50",
    "aria-label": "Email address"
  }), /*#__PURE__*/React.createElement("button", {
    type: "submit",
    disabled: status === "loading",
    className: "rounded-full bg-charcoal px-6 py-3 text-sm font-medium tracking-wide text-cream transition hover:bg-charcoal-800 active:scale-[0.98] disabled:opacity-50"
  }, status === "loading" ? "Adding…" : "Notify me")), message && /*#__PURE__*/React.createElement("p", {
    className: `mt-3 text-xs ${status === "ok" ? "text-charcoal/70" : "text-red-700/70"}`,
    role: "status"
  }, message), /*#__PURE__*/React.createElement("div", {
    className: "mt-12 grid w-full max-w-md grid-cols-3 gap-4 text-[11px] uppercase tracking-widest text-charcoal/55"
  }, /*#__PURE__*/React.createElement("div", {
    className: "flex flex-col items-center gap-1.5"
  }, /*#__PURE__*/React.createElement(Sparkle, null), /*#__PURE__*/React.createElement("span", null, "925 Silver")), /*#__PURE__*/React.createElement("div", {
    className: "flex flex-col items-center gap-1.5"
  }, /*#__PURE__*/React.createElement(Heart, null), /*#__PURE__*/React.createElement("span", null, "Personalized")), /*#__PURE__*/React.createElement("div", {
    className: "flex flex-col items-center gap-1.5"
  }, /*#__PURE__*/React.createElement(Leaf, null), /*#__PURE__*/React.createElement("span", null, "Made to Order")))), /*#__PURE__*/React.createElement("footer", {
    className: "flex flex-col items-center gap-3 text-[11px] uppercase tracking-widest text-charcoal/50 sm:flex-row sm:justify-between"
  }, /*#__PURE__*/React.createElement("span", null, "\xA9 2026 Swarom"), /*#__PURE__*/React.createElement("div", {
    className: "flex items-center gap-5"
  }, /*#__PURE__*/React.createElement("a", {
    href: "https://wa.me/919999999999?text=Hi%20Swarom%2C%20I%27d%20love%20to%20know%20when%20you%20launch.",
    target: "_blank",
    rel: "noopener noreferrer",
    className: "hover:text-charcoal"
  }, "WhatsApp"), /*#__PURE__*/React.createElement("a", {
    href: "https://instagram.com/swarom.in",
    target: "_blank",
    rel: "noopener noreferrer",
    className: "hover:text-charcoal"
  }, "Instagram"), /*#__PURE__*/React.createElement("a", {
    href: "mailto:hello@swarom.in",
    className: "hover:text-charcoal"
  }, "Email")))));
}

/* ---------- tiny inline icons (no extra package) ---------- */

function Sparkle() {
  return /*#__PURE__*/React.createElement("svg", {
    width: "16",
    height: "16",
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: "1.4",
    strokeLinecap: "round",
    strokeLinejoin: "round",
    "aria-hidden": true
  }, /*#__PURE__*/React.createElement("path", {
    d: "M12 2l1.8 5.2L19 9l-5.2 1.8L12 16l-1.8-5.2L5 9l5.2-1.8L12 2z"
  }), /*#__PURE__*/React.createElement("path", {
    d: "M19 16l.9 2.1L22 19l-2.1.9L19 22l-.9-2.1L16 19l2.1-.9L19 16z"
  }));
}
function Heart() {
  return /*#__PURE__*/React.createElement("svg", {
    width: "16",
    height: "16",
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: "1.4",
    strokeLinecap: "round",
    strokeLinejoin: "round",
    "aria-hidden": true
  }, /*#__PURE__*/React.createElement("path", {
    d: "M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8l1 1L12 21l7.8-7.6 1-1a5.5 5.5 0 0 0 0-7.8z"
  }));
}
function Leaf() {
  return /*#__PURE__*/React.createElement("svg", {
    width: "16",
    height: "16",
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: "1.4",
    strokeLinecap: "round",
    strokeLinejoin: "round",
    "aria-hidden": true
  }, /*#__PURE__*/React.createElement("path", {
    d: "M11 20A7 7 0 0 1 4 13c0-6 5-10 16-10 0 11-4 16-9 17z"
  }), /*#__PURE__*/React.createElement("path", {
    d: "M2 22c4-4 8-6 14-8"
  }));
}
Object.assign(__ds_scope, { Home });
})(); } catch (e) { __ds_ns.__errors.push({ path: "reference/swarom_page.tsx", error: String((e && e.message) || e) }); }

// reference/swarom_tailwind.config.ts
try { (() => {
const config = {
  content: ["./src/pages/**/*.{js,ts,jsx,tsx,mdx}", "./src/components/**/*.{js,ts,jsx,tsx,mdx}", "./src/app/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      colors: {
        // Swarom brand palette
        cream: {
          DEFAULT: "#F6F1EA",
          50: "#FBF8F4",
          100: "#F6F1EA",
          200: "#EDE3D4"
        },
        charcoal: {
          DEFAULT: "#1F1B16",
          800: "#2A241D",
          700: "#3A332A"
        },
        silver: {
          DEFAULT: "#C9C7C2",
          light: "#E6E4DF",
          dark: "#9A9893"
        },
        gold: {
          DEFAULT: "#B8956A"
        }
      },
      fontFamily: {
        serif: ["var(--font-serif)", "Georgia", "serif"],
        sans: ["var(--font-sans)", "system-ui", "sans-serif"]
      },
      letterSpacing: {
        wider: "0.08em",
        widest: "0.2em"
      }
    }
  },
  plugins: []
};
Object.assign(__ds_scope, { config });
})(); } catch (e) { __ds_ns.__errors.push({ path: "reference/swarom_tailwind.config.ts", error: String((e && e.message) || e) }); }

// ui_kits/website/App.jsx
try { (() => {
/* global React, Header, Footer, Home, Shop, ProductDetail, Story, BagDrawer */
const {
  useState: useStateApp
} = React;
function App() {
  const [route, setRoute] = useStateApp("home");
  const [bag, setBag] = useStateApp([]);
  const [bagOpen, setBagOpen] = useStateApp(false);
  const addToBag = item => {
    setBag(b => [...b, item]);
    setBagOpen(true);
  };
  const removeFromBag = idx => setBag(b => b.filter((_, i) => i !== idx));
  let page = null;
  if (route === "home") page = /*#__PURE__*/React.createElement(Home, {
    setRoute: setRoute
  });else if (route === "shop" || route === "collections") page = /*#__PURE__*/React.createElement(Shop, {
    setRoute: setRoute
  });else if (route === "product") page = /*#__PURE__*/React.createElement(ProductDetail, {
    addToBag: addToBag,
    setRoute: setRoute
  });else if (route === "story" || route === "care") page = /*#__PURE__*/React.createElement(Story, null);
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Header, {
    route: route,
    setRoute: setRoute,
    bag: bag,
    openBag: () => setBagOpen(true)
  }), page, /*#__PURE__*/React.createElement(Footer, null), /*#__PURE__*/React.createElement(BagDrawer, {
    open: bagOpen,
    bag: bag,
    removeFromBag: removeFromBag,
    onClose: () => setBagOpen(false)
  }));
}
const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(/*#__PURE__*/React.createElement(App, null));
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/website/App.jsx", error: String((e && e.message) || e) }); }

// ui_kits/website/BagDrawer.jsx
try { (() => {
/* global React */
function BagDrawer({
  open,
  bag,
  removeFromBag,
  onClose
}) {
  if (!open) return null;
  const subtotal = bag.reduce((s, it) => s + it.price, 0);
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    className: "kit-drawer-scrim",
    onClick: onClose
  }), /*#__PURE__*/React.createElement("aside", {
    className: "kit-drawer"
  }, /*#__PURE__*/React.createElement("header", {
    className: "kit-drawer-head"
  }, /*#__PURE__*/React.createElement("span", {
    className: "kit-drawer-title"
  }, "Your bag ", /*#__PURE__*/React.createElement("span", {
    className: "mono-count"
  }, "/ ", bag.length, " /")), /*#__PURE__*/React.createElement("button", {
    className: "navicon",
    onClick: onClose,
    "aria-label": "Close"
  }, /*#__PURE__*/React.createElement("svg", {
    width: "14",
    height: "14"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-close"
  })))), bag.length === 0 ? /*#__PURE__*/React.createElement("div", {
    className: "kit-drawer-empty"
  }, /*#__PURE__*/React.createElement("p", {
    className: "serif-italic",
    style: {
      fontSize: 20,
      color: "var(--fg2)",
      margin: 0
    }
  }, "Your bag is quiet."), /*#__PURE__*/React.createElement("p", {
    className: "lede",
    style: {
      maxWidth: 280,
      fontSize: 14
    }
  }, "Pieces you add will rest here, ready when you are.")) : /*#__PURE__*/React.createElement("ul", {
    className: "kit-drawer-list"
  }, bag.map((item, i) => /*#__PURE__*/React.createElement("li", {
    key: i,
    className: "kit-drawer-item"
  }, /*#__PURE__*/React.createElement("img", {
    src: "../../assets/product-pendant.svg",
    alt: ""
  }), /*#__PURE__*/React.createElement("div", {
    className: "kit-drawer-info"
  }, /*#__PURE__*/React.createElement("strong", null, item.name), /*#__PURE__*/React.createElement("span", {
    className: "meta"
  }, "Engraved \xB7 ", /*#__PURE__*/React.createElement("i", null, item.engraving)), /*#__PURE__*/React.createElement("span", {
    className: "meta"
  }, "Chain \xB7 ", item.chain)), /*#__PURE__*/React.createElement("div", {
    className: "kit-drawer-side"
  }, /*#__PURE__*/React.createElement("span", {
    className: "pdp-price"
  }, "\u20B9 ", item.price.toLocaleString("en-IN")), /*#__PURE__*/React.createElement("button", {
    className: "link",
    onClick: () => removeFromBag(i)
  }, "Remove"))))), bag.length > 0 && /*#__PURE__*/React.createElement("footer", {
    className: "kit-drawer-foot"
  }, /*#__PURE__*/React.createElement("div", {
    className: "kit-drawer-subtotal"
  }, /*#__PURE__*/React.createElement("span", null, "Subtotal"), /*#__PURE__*/React.createElement("span", {
    className: "pdp-price"
  }, "\u20B9 ", subtotal.toLocaleString("en-IN"))), /*#__PURE__*/React.createElement("p", {
    className: "meta tiny"
  }, "Shipping & taxes calculated at checkout."), /*#__PURE__*/React.createElement("button", {
    className: "btn btn-primary big block"
  }, "Checkout"), /*#__PURE__*/React.createElement("button", {
    className: "btn btn-link block"
  }, "Continue browsing"))));
}
window.BagDrawer = BagDrawer;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/website/BagDrawer.jsx", error: String((e && e.message) || e) }); }

// ui_kits/website/Footer.jsx
try { (() => {
/* global React */
function Footer() {
  return /*#__PURE__*/React.createElement("footer", {
    className: "kit-footer"
  }, /*#__PURE__*/React.createElement("div", {
    className: "kit-footer-top"
  }, /*#__PURE__*/React.createElement("div", {
    className: "kit-footer-brand"
  }, /*#__PURE__*/React.createElement("div", {
    className: "kit-footer-wordmark"
  }, "Swarom"), /*#__PURE__*/React.createElement("p", {
    className: "kit-footer-tagline"
  }, "Personalized 925 sterling silver, handcrafted in Bengaluru."), /*#__PURE__*/React.createElement("div", {
    className: "kit-shimmer-line"
  })), /*#__PURE__*/React.createElement("div", {
    className: "kit-footer-cols"
  }, /*#__PURE__*/React.createElement("div", {
    className: "kit-footer-col"
  }, /*#__PURE__*/React.createElement("span", {
    className: "kit-footer-label"
  }, "Shop"), /*#__PURE__*/React.createElement("a", null, "All pieces"), /*#__PURE__*/React.createElement("a", null, "Pendants"), /*#__PURE__*/React.createElement("a", null, "Rings"), /*#__PURE__*/React.createElement("a", null, "Bracelets"), /*#__PURE__*/React.createElement("a", null, "Anklets")), /*#__PURE__*/React.createElement("div", {
    className: "kit-footer-col"
  }, /*#__PURE__*/React.createElement("span", {
    className: "kit-footer-label"
  }, "Help"), /*#__PURE__*/React.createElement("a", null, "Care guide"), /*#__PURE__*/React.createElement("a", null, "Shipping"), /*#__PURE__*/React.createElement("a", null, "Returns"), /*#__PURE__*/React.createElement("a", null, "Sizing")), /*#__PURE__*/React.createElement("div", {
    className: "kit-footer-col"
  }, /*#__PURE__*/React.createElement("span", {
    className: "kit-footer-label"
  }, "Reach"), /*#__PURE__*/React.createElement("a", null, /*#__PURE__*/React.createElement("svg", {
    width: "12",
    height: "12"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-whatsapp"
  })), "\xA0 WhatsApp"), /*#__PURE__*/React.createElement("a", null, /*#__PURE__*/React.createElement("svg", {
    width: "12",
    height: "12"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-instagram"
  })), "\xA0 Instagram"), /*#__PURE__*/React.createElement("a", null, /*#__PURE__*/React.createElement("svg", {
    width: "12",
    height: "12"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-mail"
  })), "\xA0 hello@swarom.in")), /*#__PURE__*/React.createElement("div", {
    className: "kit-footer-col"
  }, /*#__PURE__*/React.createElement("span", {
    className: "kit-footer-label"
  }, "Newsletter"), /*#__PURE__*/React.createElement("p", {
    style: {
      fontFamily: "var(--font-sans)",
      fontSize: 12,
      color: "var(--fg3)",
      lineHeight: 1.5,
      margin: 0,
      marginBottom: 8
    }
  }, "One quiet letter each month. New pieces, behind the bench."), /*#__PURE__*/React.createElement("form", {
    className: "kit-mini-form",
    onSubmit: e => e.preventDefault()
  }, /*#__PURE__*/React.createElement("input", {
    placeholder: "your@email.com"
  }), /*#__PURE__*/React.createElement("button", null, "Notify me"))))), /*#__PURE__*/React.createElement("div", {
    className: "kit-footer-bottom"
  }, /*#__PURE__*/React.createElement("span", null, "\xA9 2026 Swarom"), /*#__PURE__*/React.createElement("span", {
    className: "hairline-rule"
  }, /*#__PURE__*/React.createElement("span", null), /*#__PURE__*/React.createElement("em", null, "Bengaluru \xB7 Est. 2026"), /*#__PURE__*/React.createElement("span", null)), /*#__PURE__*/React.createElement("span", null, "Privacy \xA0\xB7\xA0 Terms")));
}
window.Footer = Footer;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/website/Footer.jsx", error: String((e && e.message) || e) }); }

// ui_kits/website/Header.jsx
try { (() => {
/* global React */
const {
  useState
} = React;
function Header({
  route,
  setRoute,
  bag,
  openBag
}) {
  const link = (id, label) => /*#__PURE__*/React.createElement("button", {
    key: id,
    onClick: () => setRoute(id),
    className: "navlink",
    "data-active": route === id || undefined
  }, label);
  return /*#__PURE__*/React.createElement("header", {
    className: "kit-header"
  }, /*#__PURE__*/React.createElement("div", {
    className: "kit-header-inner"
  }, /*#__PURE__*/React.createElement("nav", {
    className: "kit-nav-left"
  }, link("shop", "Shop"), link("collections", "Collections"), link("story", "Story"), link("care", "Care")), /*#__PURE__*/React.createElement("button", {
    className: "kit-wordmark",
    onClick: () => setRoute("home")
  }, "Swarom"), /*#__PURE__*/React.createElement("div", {
    className: "kit-nav-right"
  }, /*#__PURE__*/React.createElement("button", {
    className: "navicon",
    "aria-label": "Search"
  }, /*#__PURE__*/React.createElement("svg", {
    width: "16",
    height: "16"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-search"
  }))), /*#__PURE__*/React.createElement("button", {
    className: "navicon",
    "aria-label": "Account"
  }, /*#__PURE__*/React.createElement("svg", {
    width: "16",
    height: "16"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-user"
  }))), /*#__PURE__*/React.createElement("button", {
    className: "navicon bag",
    "aria-label": "Bag",
    onClick: openBag
  }, /*#__PURE__*/React.createElement("svg", {
    width: "16",
    height: "16"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-bag"
  })), /*#__PURE__*/React.createElement("span", {
    className: "bag-count"
  }, "/ ", bag.length, " /")))), /*#__PURE__*/React.createElement("div", {
    className: "kit-eyebrow-strip"
  }, /*#__PURE__*/React.createElement("span", null, "Free shipping across India"), /*#__PURE__*/React.createElement("span", null, "\xB7"), /*#__PURE__*/React.createElement("span", null, "Made to order in Bengaluru"), /*#__PURE__*/React.createElement("span", null, "\xB7"), /*#__PURE__*/React.createElement("span", null, "30-day returns")));
}
window.Header = Header;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/website/Header.jsx", error: String((e && e.message) || e) }); }

// ui_kits/website/Home.jsx
try { (() => {
/* global React */
const {
  useState: useStateHome
} = React;
function AmbientOrbs() {
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    "aria-hidden": true,
    className: "orb orb-1 swr-float"
  }), /*#__PURE__*/React.createElement("div", {
    "aria-hidden": true,
    className: "orb orb-2 swr-float",
    style: {
      animationDelay: "2s"
    }
  }));
}
function Home({
  setRoute
}) {
  return /*#__PURE__*/React.createElement("main", {
    className: "kit-home"
  }, /*#__PURE__*/React.createElement(AmbientOrbs, null), /*#__PURE__*/React.createElement("section", {
    className: "kit-hero"
  }, /*#__PURE__*/React.createElement("div", {
    className: "kit-hero-text"
  }, /*#__PURE__*/React.createElement("span", {
    className: "hairline-rule eyebrow"
  }, /*#__PURE__*/React.createElement("span", null), /*#__PURE__*/React.createElement("em", null, "The Everyday Collection"), /*#__PURE__*/React.createElement("span", null)), /*#__PURE__*/React.createElement("h1", {
    className: "serif-display"
  }, "Elegance Is a Way Of", /*#__PURE__*/React.createElement("br", null), "Expression And", /*#__PURE__*/React.createElement("br", null), "It Lasts Longer Than Life"), /*#__PURE__*/React.createElement("div", {
    className: "kit-signature kit-signature-brand"
  }, "Swarom"), /*#__PURE__*/React.createElement("p", {
    className: "lede"
  }, "Personalized 925 sterling silver jewellery, handcrafted in Bengaluru. Made to order. Made to last."), /*#__PURE__*/React.createElement("div", {
    className: "kit-cta-row"
  }, /*#__PURE__*/React.createElement("button", {
    className: "btn btn-primary",
    onClick: () => setRoute("product")
  }, "Shop the collection"), /*#__PURE__*/React.createElement("button", {
    className: "btn btn-secondary",
    onClick: () => setRoute("story")
  }, "Read our story \u2192")), /*#__PURE__*/React.createElement("div", {
    className: "kit-trust-row"
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("svg", {
    width: "16",
    height: "16"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-stamp"
  })), /*#__PURE__*/React.createElement("span", null, "925 Silver")), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("svg", {
    width: "16",
    height: "16"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-heart"
  })), /*#__PURE__*/React.createElement("span", null, "Personalized")), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("svg", {
    width: "16",
    height: "16"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-leaf"
  })), /*#__PURE__*/React.createElement("span", null, "Made to order")))), /*#__PURE__*/React.createElement("div", {
    className: "kit-hero-art"
  }, /*#__PURE__*/React.createElement("img", {
    src: "../../assets/hero-still-life.svg",
    alt: ""
  }), /*#__PURE__*/React.createElement("div", {
    className: "kit-hero-floating"
  }, /*#__PURE__*/React.createElement("img", {
    src: "../../assets/product-pendant.svg",
    alt: ""
  })))), /*#__PURE__*/React.createElement("section", {
    className: "kit-feature-band"
  }, /*#__PURE__*/React.createElement("div", {
    className: "kit-feature"
  }, /*#__PURE__*/React.createElement("span", {
    className: "kit-feature-num"
  }, "01"), /*#__PURE__*/React.createElement("span", {
    className: "kit-feature-label"
  }, "Sketch"), /*#__PURE__*/React.createElement("p", null, "Tell us a name, a date, a feeling. We sketch by hand.")), /*#__PURE__*/React.createElement("div", {
    className: "kit-feature"
  }, /*#__PURE__*/React.createElement("span", {
    className: "kit-feature-num"
  }, "02"), /*#__PURE__*/React.createElement("span", {
    className: "kit-feature-label"
  }, "Cast"), /*#__PURE__*/React.createElement("p", null, "Hand-cast in 925 sterling silver in our Bengaluru studio.")), /*#__PURE__*/React.createElement("div", {
    className: "kit-feature"
  }, /*#__PURE__*/React.createElement("span", {
    className: "kit-feature-num"
  }, "03"), /*#__PURE__*/React.createElement("span", {
    className: "kit-feature-label"
  }, "Send"), /*#__PURE__*/React.createElement("p", null, "Polished, packaged, and on its way within 10 days."))), /*#__PURE__*/React.createElement("section", {
    className: "kit-grid-section"
  }, /*#__PURE__*/React.createElement("div", {
    className: "kit-section-head"
  }, /*#__PURE__*/React.createElement("span", {
    className: "hairline-rule eyebrow"
  }, /*#__PURE__*/React.createElement("span", null), /*#__PURE__*/React.createElement("em", null, "The Collection"), /*#__PURE__*/React.createElement("span", null)), /*#__PURE__*/React.createElement("h2", {
    className: "serif-h2"
  }, "A small, made-to-last assembly.")), /*#__PURE__*/React.createElement("div", {
    className: "kit-product-grid"
  }, HOME_PRODUCTS.map(p => /*#__PURE__*/React.createElement(ProductTile, {
    key: p.id,
    p: p,
    onClick: () => setRoute("product")
  })))), /*#__PURE__*/React.createElement("section", {
    className: "kit-story-strip"
  }, /*#__PURE__*/React.createElement("img", {
    src: "../../assets/product-bracelet.svg",
    alt: ""
  }), /*#__PURE__*/React.createElement("div", {
    className: "kit-story-text"
  }, /*#__PURE__*/React.createElement("span", {
    className: "hairline-rule eyebrow"
  }, /*#__PURE__*/React.createElement("span", null), /*#__PURE__*/React.createElement("em", null, "Behind the bench"), /*#__PURE__*/React.createElement("span", null)), /*#__PURE__*/React.createElement("h2", {
    className: "serif-h2"
  }, "Hand-finished, one piece at a time."), /*#__PURE__*/React.createElement("p", {
    className: "lede"
  }, "Every Swarom piece passes through one set of hands from sketch to send-off. We use the same 925 alloy you'd find in heirlooms, and we hallmark each piece with the date it was made."), /*#__PURE__*/React.createElement("button", {
    className: "btn btn-link",
    onClick: () => setRoute("story")
  }, "Read our story ", /*#__PURE__*/React.createElement("span", {
    "aria-hidden": true
  }, "\u2192")))));
}
function ProductTile({
  p,
  onClick
}) {
  return /*#__PURE__*/React.createElement("article", {
    className: "kit-tile",
    onClick: onClick
  }, /*#__PURE__*/React.createElement("div", {
    className: "kit-tile-image"
  }, /*#__PURE__*/React.createElement("img", {
    src: p.image,
    alt: p.name
  })), /*#__PURE__*/React.createElement("div", {
    className: "kit-tile-caption"
  }, /*#__PURE__*/React.createElement("h3", {
    className: "serif-h4"
  }, p.name, " ", /*#__PURE__*/React.createElement("i", {
    className: "kit-tile-modifier"
  }, p.modifier)), /*#__PURE__*/React.createElement("span", {
    className: "kit-tile-meta"
  }, p.meta), /*#__PURE__*/React.createElement("span", {
    className: "kit-tile-price"
  }, "\u20B9 ", p.price.toLocaleString("en-IN"))));
}
const HOME_PRODUCTS = [{
  id: "p1",
  name: "Pendant",
  modifier: "in your hand",
  meta: "925 silver · engraved",
  price: 4800,
  image: "../../assets/product-pendant.svg"
}, {
  id: "p2",
  name: "Ring",
  modifier: "for the second one",
  meta: "925 silver · date",
  price: 6200,
  image: "../../assets/product-ring.svg"
}, {
  id: "p3",
  name: "Bracelet",
  modifier: "with a charm",
  meta: "925 silver · initial",
  price: 5400,
  image: "../../assets/product-bracelet.svg"
}, {
  id: "p4",
  name: "Pendant",
  modifier: "for two",
  meta: "925 silver · double",
  price: 7200,
  image: "../../assets/product-pendant.svg"
}];
window.Home = Home;
window.ProductTile = ProductTile;
window.HOME_PRODUCTS = HOME_PRODUCTS;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/website/Home.jsx", error: String((e && e.message) || e) }); }

// ui_kits/website/ProductDetail.jsx
try { (() => {
/* global React */
const {
  useState: useStatePDP
} = React;
function ProductDetail({
  addToBag,
  setRoute
}) {
  const [engraving, setEngraving] = useStatePDP("amelia");
  const [chain, setChain] = useStatePDP("16″");
  const [thumb, setThumb] = useStatePDP(0);
  const images = ["../../assets/product-pendant.svg", "../../assets/product-bracelet.svg", "../../assets/product-ring.svg"];
  return /*#__PURE__*/React.createElement("main", {
    className: "kit-pdp"
  }, /*#__PURE__*/React.createElement("nav", {
    className: "kit-breadcrumbs"
  }, /*#__PURE__*/React.createElement("a", {
    onClick: () => setRoute("home")
  }, "Home"), /*#__PURE__*/React.createElement("span", null, "\u203A"), /*#__PURE__*/React.createElement("a", {
    onClick: () => setRoute("shop")
  }, "Shop"), /*#__PURE__*/React.createElement("span", null, "\u203A"), /*#__PURE__*/React.createElement("span", {
    className: "current"
  }, "Pendant ", /*#__PURE__*/React.createElement("i", null, "in your hand"))), /*#__PURE__*/React.createElement("section", {
    className: "kit-pdp-layout"
  }, /*#__PURE__*/React.createElement("div", {
    className: "kit-pdp-gallery"
  }, /*#__PURE__*/React.createElement("div", {
    className: "kit-pdp-thumbs"
  }, images.map((src, i) => /*#__PURE__*/React.createElement("button", {
    key: i,
    className: "kit-thumb",
    "data-active": thumb === i || undefined,
    onClick: () => setThumb(i)
  }, /*#__PURE__*/React.createElement("img", {
    src: src,
    alt: ""
  })))), /*#__PURE__*/React.createElement("div", {
    className: "kit-pdp-main"
  }, /*#__PURE__*/React.createElement("img", {
    src: images[thumb],
    alt: ""
  }), /*#__PURE__*/React.createElement("div", {
    className: "kit-pdp-grain swr-grain"
  }))), /*#__PURE__*/React.createElement("aside", {
    className: "kit-pdp-aside"
  }, /*#__PURE__*/React.createElement("span", {
    className: "hairline-rule eyebrow"
  }, /*#__PURE__*/React.createElement("span", null), /*#__PURE__*/React.createElement("em", null, "The Everyday"), /*#__PURE__*/React.createElement("span", null)), /*#__PURE__*/React.createElement("h1", {
    className: "serif-h1 pdp-title"
  }, "Pendant ", /*#__PURE__*/React.createElement("i", null, "in your hand")), /*#__PURE__*/React.createElement("p", {
    className: "lede"
  }, "A small silver droplet on a fine cable chain. Engrave a name, a word, a date \u2014 whatever you carry."), /*#__PURE__*/React.createElement("div", {
    className: "kit-pdp-price-row"
  }, /*#__PURE__*/React.createElement("span", {
    className: "pdp-price"
  }, "\u20B9 4,800"), /*#__PURE__*/React.createElement("span", {
    className: "pdp-meta"
  }, "925 silver \xB7 made in 10 days")), /*#__PURE__*/React.createElement("div", {
    className: "kit-pdp-divider"
  }), /*#__PURE__*/React.createElement("div", {
    className: "kit-pdp-field"
  }, /*#__PURE__*/React.createElement("label", {
    className: "field-label"
  }, "Engraving"), /*#__PURE__*/React.createElement("div", {
    className: "field-input"
  }, /*#__PURE__*/React.createElement("input", {
    value: engraving,
    onChange: e => setEngraving(e.target.value.slice(0, 12)),
    maxLength: 12
  }), /*#__PURE__*/React.createElement("span", {
    className: "field-counter"
  }, engraving.length, "/12")), /*#__PURE__*/React.createElement("div", {
    className: "kit-pdp-preview"
  }, /*#__PURE__*/React.createElement("span", {
    className: "serif-italic"
  }, engraving || "—"))), /*#__PURE__*/React.createElement("div", {
    className: "kit-pdp-field"
  }, /*#__PURE__*/React.createElement("label", {
    className: "field-label"
  }, "Chain length"), /*#__PURE__*/React.createElement("div", {
    className: "kit-chip-row"
  }, ["14″", "16″", "18″", "20″"].map(c => /*#__PURE__*/React.createElement("button", {
    key: c,
    className: "kit-pill",
    "data-active": chain === c || undefined,
    onClick: () => setChain(c)
  }, c)))), /*#__PURE__*/React.createElement("div", {
    className: "kit-pdp-cta"
  }, /*#__PURE__*/React.createElement("button", {
    className: "btn btn-primary big",
    onClick: () => addToBag({
      name: "Pendant in your hand",
      engraving,
      chain,
      price: 4800
    })
  }, "Add to bag \u2014 \u20B9 4,800"), /*#__PURE__*/React.createElement("button", {
    className: "btn btn-link"
  }, /*#__PURE__*/React.createElement("svg", {
    width: "12",
    height: "12"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-whatsapp"
  })), " \xA0Ask on WhatsApp")), /*#__PURE__*/React.createElement("ul", {
    className: "kit-pdp-bullets"
  }, /*#__PURE__*/React.createElement("li", null, /*#__PURE__*/React.createElement("svg", {
    width: "14",
    height: "14"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-stamp"
  })), "Hallmarked 925 sterling silver"), /*#__PURE__*/React.createElement("li", null, /*#__PURE__*/React.createElement("svg", {
    width: "14",
    height: "14"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-truck"
  })), "Free shipping across India"), /*#__PURE__*/React.createElement("li", null, /*#__PURE__*/React.createElement("svg", {
    width: "14",
    height: "14"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-shield"
  })), "30-day return \u2014 engraved pieces included")), /*#__PURE__*/React.createElement("details", {
    className: "kit-pdp-accordion"
  }, /*#__PURE__*/React.createElement("summary", null, "Details & care ", /*#__PURE__*/React.createElement("svg", {
    width: "12",
    height: "12"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-chevron-down"
  }))), /*#__PURE__*/React.createElement("p", null, "Wipe with the cotton cloth that comes in your box. Avoid perfume and pool water. Silver darkens with time \u2014 that's the patina; rub it lightly to bring back the shine.")), /*#__PURE__*/React.createElement("details", {
    className: "kit-pdp-accordion"
  }, /*#__PURE__*/React.createElement("summary", null, "How it's made ", /*#__PURE__*/React.createElement("svg", {
    width: "12",
    height: "12"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-chevron-down"
  }))), /*#__PURE__*/React.createElement("p", null, "Each piece is cast individually from your engraving, then hand-finished and polished. We mark every pendant with the year it was made.")))));
}
window.ProductDetail = ProductDetail;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/website/ProductDetail.jsx", error: String((e && e.message) || e) }); }

// ui_kits/website/Shop.jsx
try { (() => {
/* global React, HOME_PRODUCTS, ProductTile */
function Shop({
  setRoute
}) {
  const all = [...HOME_PRODUCTS, ...HOME_PRODUCTS].map((p, i) => ({
    ...p,
    id: p.id + "-" + i
  }));
  return /*#__PURE__*/React.createElement("main", {
    className: "kit-shop"
  }, /*#__PURE__*/React.createElement("section", {
    className: "kit-shop-head"
  }, /*#__PURE__*/React.createElement("span", {
    className: "hairline-rule eyebrow"
  }, /*#__PURE__*/React.createElement("span", null), /*#__PURE__*/React.createElement("em", null, "Shop \xB7 All pieces"), /*#__PURE__*/React.createElement("span", null)), /*#__PURE__*/React.createElement("h1", {
    className: "serif-h1"
  }, "The Collection"), /*#__PURE__*/React.createElement("p", {
    className: "lede",
    style: {
      maxWidth: 560,
      margin: "12px auto 0",
      textAlign: "center"
    }
  }, "Twelve pieces. Each one personalized \u2014 a name, a date, a small mark.")), /*#__PURE__*/React.createElement("div", {
    className: "kit-shop-filters"
  }, /*#__PURE__*/React.createElement("div", {
    className: "kit-filter-row"
  }, /*#__PURE__*/React.createElement("span", {
    className: "kit-filter-label"
  }, "Filter"), ["All", "Pendants", "Rings", "Bracelets", "Anklets", "For two"].map((f, i) => /*#__PURE__*/React.createElement("button", {
    key: f,
    className: "kit-pill",
    "data-active": i === 0 || undefined
  }, f))), /*#__PURE__*/React.createElement("div", {
    className: "kit-filter-row"
  }, /*#__PURE__*/React.createElement("span", {
    className: "kit-filter-label"
  }, "Sort"), /*#__PURE__*/React.createElement("button", {
    className: "kit-pill ghost"
  }, "Newest ", /*#__PURE__*/React.createElement("svg", {
    width: "10",
    height: "10"
  }, /*#__PURE__*/React.createElement("use", {
    href: "../../assets/icons.svg#swr-chevron-down"
  }))))), /*#__PURE__*/React.createElement("section", {
    className: "kit-product-grid wide"
  }, all.map(p => /*#__PURE__*/React.createElement(ProductTile, {
    key: p.id,
    p: p,
    onClick: () => setRoute("product")
  }))));
}
window.Shop = Shop;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/website/Shop.jsx", error: String((e && e.message) || e) }); }

// ui_kits/website/Story.jsx
try { (() => {
/* global React */
function Story() {
  return /*#__PURE__*/React.createElement("main", {
    className: "kit-story"
  }, /*#__PURE__*/React.createElement("section", {
    className: "kit-story-hero"
  }, /*#__PURE__*/React.createElement("span", {
    className: "hairline-rule eyebrow"
  }, /*#__PURE__*/React.createElement("span", null), /*#__PURE__*/React.createElement("em", null, "Our Story"), /*#__PURE__*/React.createElement("span", null)), /*#__PURE__*/React.createElement("h1", {
    className: "serif-display"
  }, "We make one thing.", /*#__PURE__*/React.createElement("br", null), /*#__PURE__*/React.createElement("i", null, "We try to make it well.")), /*#__PURE__*/React.createElement("div", {
    className: "kit-shimmer-line"
  }), /*#__PURE__*/React.createElement("p", {
    className: "lede"
  }, "Swarom is a small studio in Bengaluru. We make personalized silver jewellery \u2014 the kind you wear every day, with a name or a date hidden where only you can find it.")), /*#__PURE__*/React.createElement("section", {
    className: "kit-story-grid"
  }, /*#__PURE__*/React.createElement("figure", {
    className: "kit-story-figure"
  }, /*#__PURE__*/React.createElement("img", {
    src: "../../assets/product-bracelet.svg",
    alt: ""
  }), /*#__PURE__*/React.createElement("figcaption", null, "The bench, 8 a.m.")), /*#__PURE__*/React.createElement("div", {
    className: "kit-story-prose"
  }, /*#__PURE__*/React.createElement("h2", {
    className: "serif-h2"
  }, "From the maker"), /*#__PURE__*/React.createElement("p", null, "I started Swarom because I couldn't find what I was looking for \u2014 silver that felt like a heirloom, but priced like an everyday thing. So I learned to cast, and to engrave, and to listen carefully when someone tells me a name."), /*#__PURE__*/React.createElement("p", null, "Every piece passes through one set of hands, from sketch to send-off. We never make more than we can polish carefully. It takes about ten days to make a piece. We think that's just right."), /*#__PURE__*/React.createElement("p", {
    className: "kit-signature"
  }, "\u2014 Anjali \xB7 founder"))), /*#__PURE__*/React.createElement("section", {
    className: "kit-press-strip"
  }, /*#__PURE__*/React.createElement("span", {
    className: "kit-press-label"
  }, "As seen in"), /*#__PURE__*/React.createElement("div", {
    className: "kit-press-logos"
  }, /*#__PURE__*/React.createElement("span", {
    className: "serif-italic"
  }, "The Hindu"), /*#__PURE__*/React.createElement("span", {
    className: "serif-italic"
  }, "Vogue India"), /*#__PURE__*/React.createElement("span", {
    className: "serif-italic"
  }, "Mint Lounge"), /*#__PURE__*/React.createElement("span", {
    className: "serif-italic"
  }, "Conde Nast Traveller"))));
}
window.Story = Story;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/website/Story.jsx", error: String((e && e.message) || e) }); }

__ds_ns.Home = __ds_scope.Home;

})();
