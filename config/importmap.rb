# Pin engine JavaScript
pin "application", to: "upright/application.js"
pin "upright/application", to: "upright/application.js"
pin "upright/controllers/application", to: "upright/controllers/application.js"
pin "upright/controllers", to: "upright/controllers/index.js"

pin_all_from Upright::Engine.root.join("app/javascript/upright/controllers"),
             under: "upright/controllers",
             to: "upright/controllers"

# Dependencies
pin "@hotwired/turbo-rails", to: "https://cdn.jsdelivr.net/npm/@hotwired/turbo-rails@8.0.20/+esm"
pin "@hotwired/turbo", to: "https://cdn.jsdelivr.net/npm/@hotwired/turbo@8.0.20/+esm"
pin "@hotwired/stimulus", to: "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3.2.2/dist/stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@rails/actioncable/src", to: "https://cdn.jsdelivr.net/npm/@rails/actioncable@8.1.100/src/index.js"
pin "leaflet", to: "https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet-src.esm.js"
pin "frappe-charts", to: "https://cdn.jsdelivr.net/npm/frappe-charts@1.6.2/dist/frappe-charts.min.esm.js"
pin "local-time", to: "local-time.es2017-esm.js", preload: true
