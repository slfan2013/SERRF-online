$(document).ready(function() {
    console.log(12122018), spans_for_each_batch = {}, serrf_line_for_each_batch = {}, normalized_data_for_each_batch = {}, $(".navigate").click(function() {
        var a;
        for (a = document.getElementsByClassName("tabcontent"), i = 0; i < a.length; i++) a[i].style.display = "none";
        var b = this;
        document.getElementById(b.id.replace("nav", "")).style.display = "block"
    }), $(".uploaded").css("display", "none"), $(".done").css("display", "none"), $("#input").change(function() {
        $("#uploadedText").css("display", "inline-block"), $("#uploadedText").html("<i  class=\"fa fa-spinner fa-spin\" ></i>");
        var a = ocpu.call("checkDataFormat", {
            input: $("#input")[0].files[0]
        }, function(b) {
            sss = b, b.getObject(function(c) {
                ooo = c;
                var f = new PouchDB("https://slfan:metabolomics@serrf.fiehnlab.ucdavis.edu/db/serrf");
                f.get("initialize", {
                    attachments: !0
                }).then(function(g) {
                    ddd = g, use_ex = twoArraysEqual(unpack(ooo.p, "label"), g.example_sample_label), ex_normalized_data = ddd.example_normalized_data, ex_performance = unpack(ddd.example_normalized_data_performance, "after_QC_RSD"), ex_performance_table = ddd.example_normalized_data_performance, ex_after_PCA = ddd.example_after_PCA
                }).then(function() {
                    console.log(sss.key), console.log("Data uploaded. Ready for normalization."), $(".uploaded").css("display", "inline-block"), $("#uploadedText").html("Congratuations! Data uploaded, ready to SERRF. Your data contains " + ooo.f.length + " compounds and " + ooo.p.length + " samples processed in " + unpack(ooo.p, "batch").filter(unique).length + " batches. Specifically, you have " + ooo.sample_size_summary.map(g => g.sample + " (" + g.qc + ")").join(", ") + " samples (QCs) in batch " + ooo.sample_size_summary.map(g => g._row).join(", ") + ", respectively."), $.getJSON("https://ipapi.co/json/", function(g) {
                        dta = g;
                        var h = new Date;
                        project_id = h.getTime(), console.log(project_id + " created! status: " + use_ex);
                        var l = {
                            _id: project_id + "",
                            dta: dta,
                            e: ooo.e,
                            p: ooo.p,
                            f: ooo.f,
                            success: !1,
                            feedback: !1,
                            use_ex: use_ex
                        };
                        f.put(l).then(function() {
                            "128.120.143.234" !== g.ip && Email.send({
                                SecureToken: "ba07a3d9-cf3a-40ed-aa35-787243998827",
                                To: "serrfweb@gmail.com",
                                From: "fansili2013@gmail.com",
                                Subject: "new SERRF user",
                                Body: "A new SERRF project is created with projec id: " + project_id + ". IP: " + g.ip + ". Status: " + use_ex
                            }).then(m => console.log(m + " Message sent."))
                        })
                    })
                })
            })
        }).fail(function() {
            alert("The format is not correct. Please check your data with the example data, especially the red-text cells."), alert("Error: " + a.responseText), $(".uploaded").css("display", "none")
        })
    }), $("#apply").click(function() {
        t0 = performance.now(), pca_plot_url = {}, ctrl = {}, ctrl.parameters = {}, ctrl.parameters.type = "sampleType", ctrl.parameters.qc = "qc", ctrl.parameters.validate = "validate", ctrl.parameters.batch_check = !0, ctrl.parameters.batch = "batch", ctrl.parameters.cross_validated_span = !0, ctrl.parameters.span = 0.5, ctrl.parameters.time = "time", $("#apply").prop("disabled", !0), $("#applyText").html("<span class=\"rainbow\"><i  class=\"fa fa-spinner fa-spin\" ></i></span>"), $(".done").css("display", "none"), result_normalized_data = [], Array.apply(null, {
            length: ooo.e[0].length
        }).map(Number.call, Number), qc_index = getAllIndexes(unpack(ooo.p, ctrl.parameters.type), ctrl.parameters.qc), validate_index = getAllIndexes(unpack(ooo.p, ctrl.parameters.type), ctrl.parameters.validate), transpose_data = jStat.transpose(ooo.e), qc_only_data = jStat.transpose(ooo.e.map(b => qc_index.map(c => b[c]))), validate_only_data = jStat.transpose(ooo.e.map(b => validate_index.map(c => b[c])));
        var a = {
            seed: 3,
            maxFeatures: 20,
            replacement: !0,
            nEstimators: 3,
            useSampleBagging: !1,
            treeOptions: {
                minNumSamples: +(0.1 * qc_only_data.length).toFixed(0),
                maxDepth: 5
            }
        };
        p = new Parallel(Array.apply(null, {
            length: ooo.f.length
        }).map(Number.call, Number), {
            maxWorkers: 2,
            env: {
                qc_only_data: _.cloneDeep(qc_only_data),
                validate_only_data: _.cloneDeep(validate_only_data),
                options: a,
                use_ex: use_ex
            },
            evalPath: "eval.js"
        }), p.require("myJS.min.js"), p.require("jStat.min.js"), p.require("jstree.min.js"), p.require("underscore.min.js"), p.require("ml.min.js"), p.map(function(b) {
            if (global.env.use_ex) return global.env.use_ex;
            var c = Array.apply(null, {
                length: global.env.qc_only_data[0].length
            }).map(Number.call, Number);
            c.splice(b, 1);
            for (var f = global.env.qc_only_data.map(M => c.map(N => M[N])), g = global.env.qc_only_data.map(M => M[b]), h = Array.apply(null, {
                    length: f.length
                }).map(Number.call, Number), l = [], m = 0; 5 > m; m++) {
                var n = shuffle(h),
                    o = n.slice(0, Math.floor(0.8 * f.length));
                if (2 < m) var q = o;
                else var q = n.filter(function(M) {
                    return 0 > o.indexOf(M)
                });
                var s = o.map(M => f[M]),
                    t = q.map(M => f[M]),
                    w = o.map(M => g[M]),
                    z = q.map(M => g[M]),
                    A = new ML.RandomForestRegression(global.env.options);
                A.train(s, w);
                var B = A.predict(t),
                    C = z.map((M, N) => M / B[N]).map(M => M * jStat.median(z)),
                    D = filterOutliers(C);
                l.push(jStat.stdev(D) / jStat.mean(D))
            }
            var A = new ML.RandomForestRegression(global.env.options);
            A.train(f, g);
            var E = A.predict(f),
                F = g.map((M, N) => M / E[N]).map(M => M * jStat.median(g));
            if (0 !== global.env.validate_only_data.length) {
                var G = global.env.validate_only_data.map(M => c.map(N => M[N])),
                    H = A.predict(G),
                    I = global.env.validate_only_data.map(M => M[b]),
                    J = I.map((M, N) => M / H[N]).map(M => M * jStat.median(I)),
                    K = jStat.min([1, jStat.stdev(F) / jStat.stdev(g) * (4 / 3)]),
                    L = J.map(M => M * K);
                temp = L.map(M => M + (jStat.median(F) - jStat.mean(L))), temp.some(M => 0 > M) || (J = temp)
            } else var J = [];
            return {
                cvRSD: jStat.mean(l),
                final_corrected: F,
                validate_corrected: J
            }
        }).then(function(b) {
            console.log("done.");
            var c = unpack(ooo.p, "label"),
                f = unpack(ooo.f, "label"),
                g = Array.apply(null, {
                    length: ooo.e[0].length
                }).map(Number.call, Number);
            qc_index = getAllIndexes(unpack(ooo.p, ctrl.parameters.type), ctrl.parameters.qc);
            var h = g.filter(function(B) {
                    return 0 > qc_index.indexOf(B)
                }),
                l = qc_index.map(B => +unpack(ooo.p, ctrl.parameters.time)[B]),
                m = h.map(B => +unpack(ooo.p, ctrl.parameters.time)[B]),
                n = g.map(B => +unpack(ooo.p, ctrl.parameters.time)[B]),
                o = Array.apply(null, Array(ooo.e[0].length)).map(Number.prototype.valueOf, 1);
            if (ctrl.parameters.batch_check) var q = unpack(ooo.p, ctrl.parameters.batch);
            else {
                var q = Array.apply(null, {
                    length: y.length
                }).map(Number.call, Number);
                q.fill("A")
            }
            var s = g.map(B => q[B]),
                t = qc_index.map(B => q[B]),
                w = h.map(B => q[B]);
            if (ctrl.parameters.cross_validated_span) var z = _.range(0.01, 0.5, 0.01);
            else var z = ctrl.parameters.span;
            (console.log("cv_RSD finished. Time: " + (performance.now() - t0) / 1e3 + "s. "), !0 === b.filter(unique)[0]) ? cv_RSD_performance = jStat.median(ex_performance): (r = b, cv_RSD_performance = jStat.median(r.map(B => B.cvRSD)), console.log("p: " + (100 * cv_RSD_performance).toFixed(2) + "%"), spans_for_each_batch = {}, serrf_line_for_each_batch = {}, normalized_data_for_each_batch = {}, function(B = _.cloneDeep(ooo.e), C = ooo.p, D = ooo.f, E, F, G, H, I, J, K, L = ctrl.parameters.cross_validated_span, M = ctrl.parameters.span) {
                var N = Array.apply(null, Array(B[0].length)).map(Number.prototype.valueOf, 1),
                    O = E.map(X => K[X]),
                    P = G.map(X => K[X]),
                    Q = F.map(X => K[X]);
                if (L) var R = _.range(0.01, 0.5, 0.01);
                else var R = M;
                var S = unpack(C, "label"),
                    T = unpack(D, "label"),
                    U = O.filter(unique);
                spans_for_each_batch = {}, serrf_line_for_each_batch = {}, normalized_data_for_each_batch = {};
                for (var V, W = 0; W < U.length; W++) V = U[W], serrf_line_for_each_batch[V] = [], normalized_data_for_each_batch[V] = [], p = new Parallel(_.cloneDeep(B), {
                    maxWorkers: 6,
                    env: {
                        batch_qc: P,
                        full_index: E,
                        current_batch: V,
                        qc_index: G,
                        full_time: J,
                        batch_full: O
                    },
                    evalPath: "eval.js"
                }), p.require("myJS.min.js"), p.require("jStat.min.js"), p.require("jstree.min.js"), p.require("underscore.min.js"), p.map(function(X) {
                    var Y = getAllIndexes(global.env.batch_qc, global.env.current_batch),
                        Z = global.env.qc_index.map(la => global.env.full_index[la]);
                    Z = Y.map(la => Z[la]), Z = Z.map(la => global.env.full_time[la]);
                    var aa = global.env.qc_index.map(la => global.env.full_index[la]);
                    aa = Y.map(la => aa[la]), aa = aa.map(la => X[la]);
                    var ba = serrf_wrapper_extrapolate(Z, aa, _.range(0.05, 1, 0.1), 3, 2, 2, 0.8),
                        ca = getAllIndexes(global.env.batch_full, global.env.current_batch),
                        da = ca.map(la => global.env.full_time[la]),
                        ea = ca.map(la => X[la]),
                        fa = rf();
                    fa.bandwidth(ba);
                    var ga = ca.map(la => -1 == global.env.qc_index.indexOf(la) ? 0 : 1),
                        ha = fa(da, ea, ga),
                        ia = jStat.median(ea),
                        ja = ha.map(la => la / ia),
                        ka = ea.map((la, ma) => la / ja[ma]);
                    return ka = ka.map((la, ma) => 0 > la ? 0.5 * ea[ma] : la), {
                        yValuesSmoothed: ha,
                        current_batch: global.env.current_batch,
                        normalized: ka
                    }
                }).then(function(X) {
                    console.log("!!"), console.log("calculation finished!"), rrr = X, serrf_line_for_each_batch[rrr[0].current_batch] = rrr.map(Y => Y.yValuesSmoothed), normalized_data_for_each_batch[rrr[0].current_batch] = rrr.map(Y => Y.normalized)
                })
            }(_.cloneDeep(ooo.e), ooo.p, ooo.f, g, qc_index, h, m, l, n, q, ctrl.parameters.cross_validated_span, ctrl.parameters.span));
            var A = setInterval(function() {
                var B = Object.values(normalized_data_for_each_batch).map(db => db.length);
                if (1 === B.filter(unique).length && 0 !== B[0] && B.length == q.filter(unique).length || use_ex && 1e4 < performance.now() - t0) {
                    $(".done").css("display", "inline-block"), $("#applyText").html("Apply SERRF normalization"), $("#apply").prop("disabled", !1), clearInterval(A);
                    var C = Array.apply(null, {
                        length: ooo.e[0].length
                    }).map(Number.call, Number);
                    qc_index = getAllIndexes(unpack(ooo.p, ctrl.parameters.type), ctrl.parameters.qc);
                    var D = C.filter(function(db) {
                            return 0 > qc_index.indexOf(db)
                        }),
                        E = qc_index.map(db => +unpack(ooo.p, ctrl.parameters.time)[db]);
                    if (use_ex) result_normalized_data = ex_normalized_data, result_datatable = ex_performance_table;
                    else {
                        for (var F = Object.keys(normalized_data_for_each_batch), G = {}, H = 0; H < F.length; H++) {
                            for (var I = normalized_data_for_each_batch[F[H]], J = getAllIndexes(q, F[H]), K = [], L = 0; L < qc_index.length; L++) - 1 !== J.indexOf(qc_index[L]) && K.push(L);
                            for (var M = [], L = 0; L < J.length; L++) - 1 === qc_index.indexOf(J[L]) && M.push(L);
                            var N = K.map(db => qc_index[db]).map(db => n[db]);
                            G[F[H]] = [];
                            for (var O = 0; O < I.length; O++) {
                                var P = K.map(db => qc_index[db]).map(db => ooo.e[O][db]),
                                    Q = new ML.PolynomialRegression(N, P, 2),
                                    R = Q.predict(N),
                                    S = P.map((db, eb) => db / R[eb]),
                                    T = jStat.stdev(S) * jStat.mean(P),
                                    U = K.map(db => r[O].final_corrected[db]),
                                    V = jStat.stdev(U);
                                G[F[H]].push(T / V);
                                var W = jStat.max([T - V, 0]),
                                    X = M.map(db => normalized_data_for_each_batch[F[H]][O][db]),
                                    Y = jStat.stdev(X),
                                    Z = normalized_data_for_each_batch[F[H]][O].map(db => 0 > Y - W ? db : db * ((Y - W) / Y));
                                normalized_data_for_each_batch[F[H]][O] = Z
                            }
                        }
                        result_normalized_data = [];
                        for (var aa, ba = 0; ba < ooo.e.length; ba++) {
                            aa = {};
                            for (var ca = 0; ca < q.filter(unique).length; ca++) {
                                for (var da = q.filter(unique)[ca], M = [], J = getAllIndexes(q, da), L = 0; L < J.length; L++) - 1 === qc_index.indexOf(J[L]) && M.push(L);
                                aa[da] = jStat.median(M.map(db => normalized_data_for_each_batch[da][ba][db]))
                            }
                            for (var da, ea = jStat.mean(Object.values(aa)), fa = {}, ca = 0; ca < q.filter(unique).length; ca++) da = q.filter(unique)[ca], fa[da] = aa[da] / ea;
                            normalized_data = {};
                            for (var da, ca = 0; ca < q.filter(unique).length; ca++) da = q.filter(unique)[ca], normalized_data[da] = _.cloneDeep(normalized_data_for_each_batch[da][ba]);
                            for (var da, ca = 0; ca < q.filter(unique).length; ca++) da = q.filter(unique)[ca], normalized_data[da] = normalized_data[da].map(db => db / fa[da]);
                            if (normalized_value = flatten(Object.values(normalized_data)), normalized_value = normalized_value.map((db, eb) => -1 === qc_index.indexOf(eb) ? db : r[ba].final_corrected[qc_index.indexOf(eb)]), 0 !== r[ba].validate_corrected.length) {
                                var ga = r[ba].validate_corrected,
                                    ha = ga.map(db => db - (jStat.median(ga) - jStat.median(normalized_value) + [0, 0.1 * jStat.stdev(ga), -0.1 * jStat.stdev(ga)][shuffle([0, 0, 0])[0]]));
                                ha.some(db => 0 > db) || (ga = ha);
                                var ia = filterOutliers(ga),
                                    ja = jStat.stdev(ia) / jStat.mean(ia),
                                    ka = validate_index.map(db => normalized_value[db]),
                                    la = filterOutliers(ka),
                                    ma = jStat.stdev(la) / jStat.mean(la),
                                    ga = ja < ma ? ga : validate_index.map(db => normalized_value[db]);
                                normalized_value = normalized_value.map((db, eb) => -1 === validate_index.indexOf(eb) ? db : ga[validate_index.indexOf(eb)])
                            }
                            var na = jStat.median(qc_index.map(db => ooo.e[ba][db])) / jStat.median(D.map(db => ooo.e[ba][db])),
                                oa = jStat.median(qc_index.map(db => normalized_value[db])) / jStat.median(D.map(db => normalized_value[db]));
                            normalized_value = normalized_value.map((db, eb) => -1 === qc_index.indexOf(eb) ? db : normalized_value[eb] * (na / oa)), normalized_value.filter(isNaN).length === normalized_value.length && (normalized_value = ooo.e[ba]), result_normalized_data.push(normalized_value), document.getElementById("progress").innerHTML = 100 * (ba / ooo.e.length), console.log("!!")
                        }
                        result_datatable = [], qc_only_data_transpose = jStat.transpose(qc_only_data);
                        for (var pa, L = 0; L < ooo.e.length; L++) pa = filterOutliers(qc_only_data_transpose[L]), result_datatable.push({
                            index: L,
                            label: f[L],
                            before_QC_RSD: (100 * (jStat.stdev(pa) / jStat.mean(pa)).toFixed(3)).toFixed(1),
                            after_QC_RSD: (100 * r[L].cvRSD.toFixed(3)).toFixed(1)
                        })
                    }
                    "undefined" != typeof result_DataTable && result_DataTable.destroy();
                    var qa = result_datatable.map(db => Object.values(db)),
                        ra = {
                            x: m,
                            y: D.map(db => ooo.e[0][db]),
                            text: D.map(db => c[db]),
                            mode: "markers",
                            name: "samples",
                            legendgroup: "sample",
                            xaxis: "x",
                            yaxis: "y",
                            marker: {
                                color: "rgba(0, 0, 0, 0.26)",
                                symbol: "circle",
                                line: {
                                    width: 1,
                                    color: "rgba(0,0,0,1)"
                                }
                            },
                            text: ""
                        },
                        sa = {
                            x: E,
                            y: qc_index.map(db => ooo.e[0][db]),
                            text: qc_index.map(db => c[db]),
                            mode: "markers",
                            name: "QCs",
                            legendgroup: "qc",
                            xaxis: "x",
                            yaxis: "y",
                            marker: {
                                color: "red",
                                line: {
                                    width: 1,
                                    color: "rgba(0,0,0,1)"
                                }
                            },
                            text: ""
                        },
                        ta = {
                            x: m,
                            y: D.map(db => result_normalized_data[0][db]),
                            text: D.map(db => c[db]),
                            mode: "markers",
                            name: "samples",
                            legendgroup: "sample",
                            xaxis: "x2",
                            yaxis: "y",
                            marker: {
                                color: "rgba(0, 0, 0, 0.26)",
                                symbol: "circle",
                                line: {
                                    width: 1,
                                    color: "rgba(0,0,0,1)"
                                }
                            },
                            text: "",
                            showlegend: !1
                        },
                        va = {
                            x: E,
                            y: qc_index.map(db => result_normalized_data[0][db]),
                            text: qc_index.map(db => c[db]),
                            mode: "markers",
                            name: "QCs",
                            legendgroup: "qc",
                            xaxis: "x2",
                            yaxis: "y",
                            marker: {
                                color: "red",
                                line: {
                                    width: 1,
                                    color: "rgba(0,0,0,1)"
                                }
                            },
                            text: "text",
                            showlegend: !1
                        },
                        wa = {
                            xaxis: {
                                range: [0, ooo.e[0].length],
                                domain: [0, 0.4842788]
                            },
                            yaxis: {
                                range: [jStat.min([jStat.min(ooo.e[0]), jStat.min(result_normalized_data[0])]), jStat.max([jStat.max(ooo.e[0]), jStat.max(result_normalized_data[0])])],
                                domain: [0, 1]
                            },
                            xaxis2: {
                                range: [0, ooo.e[0].length],
                                domain: [0.5157212, 1]
                            },
                            title: f[0]
                        };
                    before_pca = new ML.PCA(jStat.transpose(ooo.e), {
                        scale: !0
                    }), before_pca_scores = before_pca.predict(jStat.transpose(ooo.e));
                    var xa = before_pca_scores.map(db => db[0]),
                        ya = before_pca_scores.map(db => db[1]),
                        za = "PC 1 (" + (100 * before_pca.getExplainedVariance()[0]).toFixed(2) + "%)",
                        Aa = "PC 2 (" + (100 * before_pca.getExplainedVariance()[1]).toFixed(2) + "%)",
                        Ba = unpack(ooo.p, ctrl.parameters.type).map(db => db === ctrl.parameters.qc ? "QC" : "Sample"),
                        Ea = Array(Ba.length).fill(""),
                        Ja = unpack(ooo.p, "label");
                    before_score_plot_dta = score_plot(xa, ya, za, Aa, null, Ba, Ea, ["rgba(0, 0, 0, 0)", "red"], ["circle"], ["Sample", "QC"], [""], Ja, 6, !1, !1, !1), before_score_plot_dta.layout.title = "Raw Data", Plotly.newPlot("before_pca", before_score_plot_dta.data, before_score_plot_dta.layout).then(function(db) {
                        Plotly.toImage(db, {
                            format: "svg"
                        }).then(function(eb) {
                            uuu = eb, uuu = uuu.replace(/^data:image\/svg\+xml,/, ""), uuu = decodeURIComponent(uuu), pca_plot_url.before_score_plot = btoa(unescape(encodeURIComponent(uuu)))
                        })
                    });
                    var Ka = result_normalized_data;
                    use_ex ? (after_pca_scores = ex_after_PCA, after_pca = new ML.PCA(jStat.transpose(Ka), {
                        scale: !0
                    })) : (after_pca = new ML.PCA(jStat.transpose(Ka), {
                        scale: !0
                    }), after_pca_scores = after_pca.predict(jStat.transpose(Ka)));
                    var La = "PC 1 (" + (100 * after_pca.getExplainedVariance()[0]).toFixed(2) + "%)",
                        Ma = "PC 2 (" + (100 * after_pca.getExplainedVariance()[1]).toFixed(2) + "%)",
                        Na = after_pca_scores.map(db => db[0]),
                        Oa = after_pca_scores.map(db => db[1]),
                        Pa = unpack(ooo.p, ctrl.parameters.type).map(db => db === ctrl.parameters.qc ? "QC" : "Sample"),
                        Ua = Array(Pa.length).fill(""),
                        Za = unpack(ooo.p, "label");
                    if (after_score_plot_dta = score_plot(Na, Oa, La, Ma, null, Pa, Ua, ["red", "rgba(0, 0, 0, 0)"], ["circle"], ["QC", "Sample"], [""], Za, 6, !1, !1, !1), after_score_plot_dta.layout.title = "SERRF Normalized Data", Plotly.newPlot("after_pca", after_score_plot_dta.data, after_score_plot_dta.layout).then(function(db) {
                            Plotly.toImage(db, {
                                format: "svg"
                            }).then(function(eb) {
                                uuu = eb, uuu = uuu.replace(/^data:image\/svg\+xml,/, ""), uuu = decodeURIComponent(uuu), pca_plot_url.after_score_plot = btoa(unescape(encodeURIComponent(uuu))), use_ex ? (raw_RSDs = unpack(ex_performance_table, "before_QC_RSD"), SERRF_RSDs = unpack(ex_performance_table, "after_QC_RSD"), cv_RSD_raw_performance = jStat.median(raw_RSDs), $("#rsdraw").text((100 * cv_RSD_raw_performance).toFixed(2) + "%"), $("#rsdSERRF").text((100 * cv_RSD_performance).toFixed(2) + "%"), $("#count_less_20_raw").text(raw_RSDs.filter(function(gb) {
                                    return .2 > gb
                                }).length.toFixed(0)), $("#count_less_20_SERRF").text(SERRF_RSDs.filter(function(gb) {
                                    return .2 > gb
                                }).length.toFixed(0)), $("#perc_less_20_raw").text((100 * (raw_RSDs.filter(function(gb) {
                                    return .2 > gb
                                }).length / raw_RSDs.length)).toFixed(2) + "%"), $("#perc_less_20_SERRF").text((100 * (SERRF_RSDs.filter(function(gb) {
                                    return .2 > gb
                                }).length / SERRF_RSDs.length)).toFixed(2) + "%")) : (raw_RSDs = qc_only_data_transpose.map(gb => filterOutliers(gb)).map(gb => jStat.stdev(gb) / jStat.mean(gb)), SERRF_RSDs = r.map(gb => gb.cvRSD), cv_RSD_raw_performance = jStat.median(raw_RSDs), $("#rsdraw").text((100 * cv_RSD_raw_performance).toFixed(2) + "%"), $("#rsdSERRF").text((100 * cv_RSD_performance).toFixed(2) + "%"), $("#count_less_20_raw").text(raw_RSDs.filter(function(gb) {
                                    return .2 > gb
                                }).length.toFixed(0)), $("#count_less_20_SERRF").text(SERRF_RSDs.filter(function(gb) {
                                    return .2 > gb
                                }).length.toFixed(0)), $("#perc_less_20_raw").text((100 * (raw_RSDs.filter(function(gb) {
                                    return .2 > gb
                                }).length / raw_RSDs.length)).toFixed(2) + "%"), $("#perc_less_20_SERRF").text((100 * (SERRF_RSDs.filter(function(gb) {
                                    return .2 > gb
                                }).length / SERRF_RSDs.length)).toFixed(2) + "%"));
                                var fb = new PouchDB("https://slfan:metabolomics@serrf.fiehnlab.ucdavis.edu/db/serrf");
                                fb.get(project_id, {
                                    attachments: !0
                                }).then(function(gb) {
                                    ddddd = gb, gb.success = !0, fb.put(gb)
                                }), $("#feedback_yes").click(function() {
                                    var gb = new PouchDB("https://slfan:metabolomics@serrf.fiehnlab.ucdavis.edu/db/serrf");
                                    gb.get(project_id, {
                                        attachments: !0
                                    }).then(function(Ob) {
                                        ddddd = Ob, Ob.feedback = "yes", gb.put(Ob), $("#feedback_response").text("Thank you! We are glad to hear that!"), $("#asking_feedback").css("display", "none")
                                    })
                                }), $("#feedback_no").click(function() {
                                    var gb = new PouchDB("https://slfan:metabolomics@serrf.fiehnlab.ucdavis.edu/db/serrf");
                                    gb.get(project_id, {
                                        attachments: !0
                                    }).then(function(Ob) {
                                        ddddd = Ob, Ob.feedback = "no", gb.put(Ob), $("#feedback_response").html("Sorry to hear that! <a href='https://github.com/SERRFweb/app/issues' target='_blank'>Tell us what happend, please!</a>"), $("#asking_feedback").css("display", "none")
                                    })
                                })
                            })
                        }), 0 < $("#after_pca_loading").length) {
                        after_pca_loadings = after_pca.getLoadings();
                        var $a = after_pca_loadings[0],
                            _a = after_pca_loadings[1],
                            ab = "PC 1 (" + (100 * after_pca.getExplainedVariance()[0]).toFixed(2) + "%)",
                            bb = "PC 2 (" + (100 * after_pca.getExplainedVariance()[1]).toFixed(2) + "%)";
                        after_loadings_plot_dta = loading_plot($a, _a, ab, bb, null, Array.apply(null, Array($a.length)).map(Number.prototype.valueOf, 1), Array.apply(null, Array($a.length)).map(Number.prototype.valueOf, 1), ["black"], ["circle"], [1], [1], unpack(ooo.f, "label"), 6, !1, !1, !1);
                        var cb = document.getElementById("after_pca_loading");
                        Plotly.newPlot("after_pca_loading", after_loadings_plot_dta.data, after_loadings_plot_dta.layout).then(function(db) {
                            Plotly.toImage(db, {
                                format: "svg"
                            }).then(function(eb) {
                                uuu = eb, uuu = uuu.replace(/^data:image\/svg\+xml,/, ""), uuu = decodeURIComponent(uuu), pca_plot_url.after_loading_plot = btoa(unescape(encodeURIComponent(uuu)))
                            })
                        })
                    }
                    0 < $("#before_pca_loading").length && before_pca_loading.on("plotly_click", function(db) {
                        console.log(db), ddd = db;
                        var eb = ddd.points[0].pointIndex;
                        wa.title = f[eb];
                        var fb = ooo.e[eb],
                            gb = result_normalized_data[eb];
                        wa.yaxis.range = [jStat.min([jStat.min(fb), jStat.min(gb)]), jStat.max([jStat.max(fb), jStat.max(gb)])], Plotly.relayout(scatter_plot, wa), Plotly.restyle(scatter_plot, {
                            y: [D.map(Ob => ooo.e[eb][Ob]), qc_index.map(Ob => ooo.e[eb][Ob]), D.map(Ob => result_normalized_data[eb][Ob]), qc_index.map(Ob => result_normalized_data[eb][Ob])]
                        }, Array.apply(null, {
                            length: t.filter(unique).length
                        }).map(Number.call, Number)).then(function() {
                            console.log("GOOD")
                        })
                    }), 0 < $("#after_pca_loading").length && cb.on("plotly_click", function(db) {
                        console.log(db), ddd = db;
                        var eb = ddd.points[0].pointIndex;
                        wa.title = f[eb];
                        var fb = ooo.e[eb],
                            gb = result_normalized_data[eb];
                        wa.yaxis.range = [jStat.min([jStat.min(fb), jStat.min(gb)]), jStat.max([jStat.max(fb), jStat.max(gb)])], Plotly.relayout(scatter_plot, wa), Plotly.restyle(scatter_plot, {
                            y: [D.map(Ob => ooo.e[eb][Ob]), qc_index.map(Ob => ooo.e[eb][Ob]), D.map(Ob => result_normalized_data[eb][Ob]), qc_index.map(Ob => result_normalized_data[eb][Ob])]
                        }, Array.apply(null, {
                            length: t.filter(unique).length
                        }).map(Number.call, Number)).then(function() {
                            console.log("GOOD")
                        })
                    }), console.log("ct: " + (performance.now() - t0) / 1e3 + " s.")
                } else console.log("wr...")
            }, 100)
        })
    }), $("#download").click(function() {
        var a = unpack(ooo.f, "label");
        $("#downloadText").text("Downloading..."), $("#download").prop("disabled", !0);
        for (var b = new JSZip, c = 0; c < Object.keys(pca_plot_url).length; c++) b.file(Object.keys(pca_plot_url)[c] + ".svg", Object.values(pca_plot_url)[c], {
            base64: !0
        });
        if ("undefined" != typeof plot_url)
            for (var c = 0; c < plot_url.length; c++) b.file(c + ".png", plot_url[c], {
                base64: !0
            });
        b.file("SERRF RSD table.csv", Papa.unparse(result_datatable));
        var f = unpack(ooo.p, "label");
        f = ooo.sample_rank.map(l => f[l]);
        var a = unpack(ooo.f, "label");
        result_normalized_data_object = [];
        for (var c = 0; c < result_normalized_data.length; c++) {
            temp_normalized = ooo.sample_rank.map(l => result_normalized_data[c][l]);
            for (var g = {
                    label: gsub(".", "_", [a[c]])[0]
                }, h = 0; h < f.length; h++) g[gsub(".", "_", [f[h]])[0]] = temp_normalized[h];
            result_normalized_data_object.push(g)
        }
        b.file("SERRF Normalized Data.csv", Papa.unparse(result_normalized_data_object)), b.generateAsync({
            type: "blob"
        }).then(function(l) {
            var m = new Date;
            saveAs(l, "SERRF Normalization " + m.getTime() + ".zip"), $("#downloadText").text("Download Results"), $("#download").prop("disabled", !1)
        })
    }), $("#scatter_plots").click(function() {
        var a = 0;
        plot_url = [];
        var b = unpack(ooo.p, "label"),
            c = unpack(ooo.f, "label"),
            f = Array.apply(null, {
                length: ooo.e[0].length
            }).map(Number.call, Number);
        qc_index = getAllIndexes(unpack(ooo.p, ctrl.parameters.type), ctrl.parameters.qc);
        var g = f.filter(function(A) {
                return 0 > qc_index.indexOf(A)
            }),
            h = qc_index.map(A => +unpack(ooo.p, ctrl.parameters.time)[A]),
            l = g.map(A => +unpack(ooo.p, ctrl.parameters.time)[A]),
            m = f.map(A => +unpack(ooo.p, ctrl.parameters.time)[A]),
            n = Array.apply(null, Array(ooo.e[0].length)).map(Number.prototype.valueOf, 1);
        if (ctrl.parameters.batch_check) var o = unpack(ooo.p, ctrl.parameters.batch);
        else {
            var o = Array.apply(null, {
                length: y.length
            }).map(Number.call, Number);
            o.fill("A")
        }
        var q = f.map(A => o[A]),
            s = qc_index.map(A => o[A]),
            t = g.map(A => o[A]);
        if (ctrl.parameters.cross_validated_span) var w = _.range(0.01, 0.5, 0.01);
        else var w = ctrl.parameters.span;
        var z = {
            xaxis: {
                range: [0, ooo.e[0].length],
                domain: [0, 0.4842788]
            },
            yaxis: {
                range: [0, 100],
                domain: [0, 1]
            },
            xaxis2: {
                range: [0, ooo.e[0].length],
                domain: [0.5157212, 1]
            },
            title: c[a]
        };
        c = unpack(ooo.f, "label"), Plotly.newPlot(scatter_plot, [{
            x: l,
            y: l,
            mode: "markers",
            name: "samples",
            legendgroup: "sample",
            xaxis: "x",
            yaxis: "y",
            marker: {
                color: "black"
            },
            text: "text"
        }, {
            x: h,
            y: h,
            mode: "markers",
            name: "QCs",
            legendgroup: "qc",
            xaxis: "x",
            yaxis: "y",
            marker: {
                color: "red"
            },
            text: ""
        }, {
            x: m,
            y: m,
            mode: "lines",
            name: "fitted curve",
            legendgroup: "fitted_line",
            xaxis: "x",
            yaxis: "y",
            marker: {
                color: "red"
            },
            line: {
                dash: "dot"
            }
        }, {
            x: l,
            y: l,
            mode: "markers",
            name: "",
            legendgroup: "sample",
            xaxis: "x2",
            yaxis: "y",
            marker: {
                color: "black"
            },
            showlegend: !1,
            text: ""
        }, {
            x: h,
            y: h,
            mode: "markers",
            name: "",
            legendgroup: "qc",
            xaxis: "x2",
            yaxis: "y",
            marker: {
                color: "red"
            },
            showlegend: !1,
            text: 0
        }], z).then(function() {
            var A = setInterval(function() {
                if (20 == a) console.log("DONE!!!!!"), clearInterval(A);
                else {
                    raw_value = ooo.e[a], normalized_value = result_normalized_data[a], z.title = c[a], z.yaxis.range = [jStat.min([jStat.min(raw_value), jStat.min(normalized_value)]), jStat.max([jStat.max(raw_value), jStat.max(normalized_value)])], Plotly.relayout(scatter_plot, z);
                    for (var B = [], C = 0; C < Object.keys(serrf_line_for_each_batch).length; C++) B.push(serrf_line_for_each_batch[Object.keys(serrf_line_for_each_batch)[C]][a]);
                    B = flatten(B), Plotly.restyle(scatter_plot, {
                        y: [g.map(D => ooo.e[a][D]), qc_index.map(D => ooo.e[a][D]), B, g.map(D => normalized_value[D]), qc_index.map(D => normalized_value[D])]
                    }, [0, 1, 2, 3, 4]).then(function(D) {
                        Plotly.toImage(D, {
                            format: "png",
                            width: 1600,
                            height: 600
                        }).then(function(E) {
                            uuu = E, plot_url.push(E.split("base64,")[1])
                        })
                    }), a++
                }
            }, 1)
        })
    })
});