#!/usr/bin/env bb

(require '[babashka.process :as p])
(require '[clojure.pprint :as pp])
(require '[clojure.string :as str])

(defmacro debug [sym] `(do (println ~(keyword sym)) (pp/pprint ~sym) (println)))

(def sinks
  (let [default-sink-name (->> (p/sh ["pactl" "info"])
                               :out
                               (re-find #"Default Sink: (\S+)")
                               second)]
    (->> (p/sh ["pactl" "list" "short" "sinks"])
         :out
         str/split-lines
         (map #(rest (re-find #"^([0-9]+)\t(\S+)" %)))
         (map #(zipmap [:number :name] %))
         (map #(assoc % :default (= (:name %) default-sink-name))))))

(debug sinks)
(assert (some :default sinks) "Default sink not found")

(def next-sink (->> sinks
                    ;; Remove crappy monitor speakers from sink candidates
                    (remove #(re-find #"hdmi-stereo" (:name %)))
                    (sort-by :number)
                    cycle
                    (reduce (fn [flag sink]
                              (cond flag (reduced sink)
                                    (:default sink) :default-sink
                                    :else nil))
                            nil)))

(debug next-sink)

(p/sh ["pactl" "set-default-sink" (:number next-sink)])
(println "Changed default sink to" (:name next-sink))
