$(document).ready(function() {
  console.log(1548435788)
  spans_for_each_batch = {}
  serrf_line_for_each_batch = {}
  normalized_data_for_each_batch = {}
  
  $(".navigate").click(function() {
    var a;
    for (a = document.getElementsByClassName("tabcontent"), i = 0; i < a.length; i++) a[i].style.display = "none";
    var b = this;
    document.getElementById(b.id.replace("nav", "")).style.display = "block"
  })
  
  $(".uploaded").css("display", "none")
  $(".done").css("display", "none")
  
  
  $("#input").change(function() {
    
    file = $("#input")[0].files[0]
    if(".csv"!==file.name.substr(file.name.length - 4)){
      alert("Input data has to be in the .csv file. Please see the example dataset 'Explanation'.")
      return;
    }
    
    $("#uploadedText").css("display", "inline-block")
    $("#uploadedText").html("<i  class=\"fa fa-spinner fa-spin\" ></i>");
    
    
    
    Papa.parse(file, {
      complete: function(results) {
        $(".uploaded").css("display", "inline-block")
        num_error = 0
        rrr = results
        rrr.data.pop();
        
        //var row_na_position = getAllIndexes(rrr.data[0],"")
        row_na_position = [0,1]
        //var col_na_position = getAllIndexes(rrr.data.map(x => x[0]),"")
        col_na_position = [0,1,2]
        
        fData = [];
        for(var i=col_na_position.length;i<rrr.data.length;i++){
          fData.push(row_na_position.map(x=>rrr.data[i][x]))
        }
        
        pData = jStat.transpose(col_na_position.concat([col_na_position.length]).map(x=>rrr.data[x]))
        pData.shift()
        
        eData = [];
        var row_not_na_position = [...Array(rrr.data[0].length).keys()]
        row_not_na_position.shift();row_not_na_position.shift();
        for(var  i=col_na_position.length;i<rrr.data.length;i++){
          eData.push(row_not_na_position.map(x=>rrr.data[i][x]))
        }
        eData.shift()
        
        var element = document.getElementById("warningMessage");
        element.innerHTML = "";
        
        
        var sum_NA = jStat.sum(eData.map(x=>x.filter(y=>y=="")).map(x=>x.length))
        if(sum_NA>0){
          var para = document.createElement("p");
          para.setAttribute("style", "color:orange;");
          var node = document.createTextNode("There are "+sum_NA+" missing values in your dataset. They are imputed by half-minimum of not missing value of the corresponding compound.");
          para.appendChild(node);
          element.appendChild(para);
        }
        if(pData[0].indexOf("label")===-1){
          var para = document.createElement("p");
          para.setAttribute("style", "color:red;");
          var node = document.createTextNode("'label' is not found in your dataset. Check the example dataset.");
          para.appendChild(node);
          element.appendChild(para);
          num_error++;
        }
        if(pData[0].indexOf("batch")===-1){
          var para = document.createElement("p");
          para.setAttribute("style", "color:red;");
          var node = document.createTextNode("'batch' is not found in your dataset. Check the example dataset.");
          para.appendChild(node);
          element.appendChild(para);
          num_error++;
        }
        if(pData[0].indexOf("sampleType")===-1){
          var para = document.createElement("p");
          para.setAttribute("style", "color:red;");
          var node = document.createTextNode("'sampleType' is not found in your dataset. Check the example dataset.");
          para.appendChild(node);
          element.appendChild(para);
          num_error++;
        }
        
        if(pData[0].indexOf("time")===-1){
          var para = document.createElement("p");
          para.setAttribute("style", "color:red;");
          var node = document.createTextNode("'time' is not found in your dataset. Check the example dataset.");
          para.appendChild(node);
          element.appendChild(para);
          num_error++;
        }
        
        
        sampleType_index = pData[0].indexOf('sampleType')
        label_index = pData[0].indexOf('label')
        
        
        
        qc_index = getAllIndexes(pData.map(x=>x[sampleType_index]),"qc")
        sample_index = getAllIndexes(pData.map(x=>x[sampleType_index]),"sample")
        if(qc_index.length<1){
          var para = document.createElement("p");
          para.setAttribute("style", "color:red;");
          var node = document.createTextNode("'qc' is not found in your dataset. Check the example dataset.");
          para.appendChild(node);
          element.appendChild(para);
          num_error++;
        }
        if(sample_index.length<1){
          var para = document.createElement("p");
          para.setAttribute("style", "color:red;");
          var node = document.createTextNode("'qc' is not found in your dataset. Check the example dataset.");
          para.appendChild(node);
          element.appendChild(para);
          num_error++;
        }
        batch_index = pData[0].indexOf('batch')
        num_qc_per_batch = _.countBy(qc_index.map(x=>pData[x]).map(x => x[batch_index]))
        if(Object.values(num_qc_per_batch).filter(x=>x<5).length>1){
          var para = document.createElement("p");
          para.setAttribute("style", "color:red;");
          var node = document.createTextNode("Each batch must have at least five qc samples.");
          para.appendChild(node);
          element.appendChild(para);
          num_error++;
        }
        if(num_error==0){
          $("#uploadedText").html("Congratuations! Data uploaded, ready to SERRF. Your data contains " + fData.length + " compounds, " + qc_index.length + " qcs and "+sample_index.length+" samples processed in " + Object.keys(num_qc_per_batch).length + " batches.")
          $("#apply").css("display", "inline-block");
          
          
          $("#apply").click(function() {
            var estimated_time = (fData.length/5.25).toFixed(0)
            $("#applyText").html("<span class=\"rainbow\"><i  class=\"fa fa-spinner fa-spin\" ></i> Estimated Calculation Time: "+estimated_time+" seconds.</span>");
            
            $("#apply").prop("disabled", !0);
            console.log("!!!")
            
            var f = new PouchDB("https://slfan:metabolomics@serrf.fiehnlab.ucdavis.edu/db/serrf");
            f.get("initialize", {
              attachments: !0
            }).then(function(g) {
              console.log("!!")
              ddd = g
              temp_index=Array.apply(null, {length: Math.min(pData.length-1,222)}).map(Number.call, Number);
              use_ex = twoArraysEqual(temp_index.map(x=>pData[x+1]).map(x=>x[label_index]), temp_index.map(x=>g.example_sample_label[x]))
              ex_normalized_data = ddd.example_normalized_data
              ex_performance = unpack(ddd.example_normalized_data_performance, "after_QC_RSD")
              ex_performance_table = ddd.example_normalized_data_performance
              ex_after_PCA = ddd.example_after_PCA
            }).then(function() {
              console.log("!!")
              // put the data to the databas
              $.getJSON("https://ipapi.co/json/", function(g) {
                dta = g;
                var time = new Date;
                project_id = Math.floor(Date.now() / 1000);console.log(project_id + " c! status: " + use_ex);
                //project_id = time.getTime(), console.log(project_id + "c! status: " + use_ex);
                var l = {
                  _id: project_id + "",
                  dta: results.data,
                  success: !1,
                  feedback: !1,
                  use_ex: use_ex
                };
                f.put(l).then(function() {
                  $(".done").css("display", "none");
                  pca_plot_url = {}
                  var before_data = eData.map(x=>x.map(y=>Number(y)))
                  before_pca = new ML.PCA(jStat.transpose(before_data), {
                    scale: !0
                  })
                  before_pca_scores = before_pca.predict(jStat.transpose(before_data))
                  var PC1_label = "PC 1 (" + (100 * before_pca.getExplainedVariance()[0]).toFixed(2) + "%)"
                  var PC2_label = "PC 2 (" + (100 * before_pca.getExplainedVariance()[1]).toFixed(2) + "%)"
                  var PC1 = before_pca_scores.map(db => db[0])
                  var PC2 = before_pca_scores.map(db => db[1])
                  var color_by = pData.map(x=>x[sampleType_index])
                  color_by.shift()
                  var shape_by = Array(color_by.length).fill("")
                  sample_label = pData.map(x=>x[label_index]);
                  sample_label.shift();
                  var before_score_plot_dta = score_plot(PC1, PC2, PC1_label, PC2_label, null, color_by, shape_by, ["red", "rgba(0, 0, 0, 0)"], ["circle"], ["qc", "sample"], [""], sample_label, 6, !1, !1, !1)
                  before_score_plot_dta.layout.title = "Raw Data"
                  Plotly.newPlot("before_pca", before_score_plot_dta.data, before_score_plot_dta.layout).then(function(db) {
                    Plotly.toImage(db, {
                      format: "svg"
                    }).then(function(url){
                      uuu = url, uuu = uuu.replace(/^data:image\/svg\+xml,/, ""), uuu = decodeURIComponent(uuu), pca_plot_url.before_score_plot = btoa(unescape(encodeURIComponent(uuu)))
                    })
                    
                  })
                  
                  "128.120.143.234" !== g.ip && "2600:1700:e1c0:7870:ed85:c9ca:fb95:2f46" !==g.ip && "168.150.116.196" !== g.ip && "2600:1700:e1c0:7870:c1b7:6ecb:cbd5:6666" !==g.ip && Email.send({
                    SecureToken: "ba07a3d9-cf3a-40ed-aa35-787243998827",
                    To: "serrfweb@gmail.com",
                    From: "fansili2013@gmail.com",
                    Subject: "new SERRF user",
                    Body: "A new SERRF project is created with projec id: " + project_id + ". IP: " + g.ip + ". Status: " + use_ex
                  }).then(function(m){m => console.log(m + " MS.")})
                  
                  // loop every 5 seconds to check the status of the project.
                  var check_project_status_interval = setInterval(function() { 
                    
                    
                    var f = new PouchDB("https://slfan:metabolomics@serrf.fiehnlab.ucdavis.edu/db/serrf");
                    f.get(project_id, {
                      attachments: !0
                    }).then(function(doc){
                      
                      ddd = doc
                      if(ddd.failed){
                        $(".done").css("display", "inline-block")
                        $("#applyText").html("Apply SERRF normalization")
                        $("#apply").prop("disabled", !1);
                        alert("Calculation Failed. Error Message: " + ddd.error_message);
                        clearInterval(check_project_status_interval);
                        return;
                      }else if(ddd.success){
                        
                        $(".done").css("display", "inline-block")
                        $("#applyText").html("Apply SERRF normalization")
                        $("#apply").prop("disabled", !1);
                        clearInterval(check_project_status_interval);
                        $("#count_less_20_SERRF").text(ddd.rsds.filter(x=>x<0.2).length) 
                        $("#perc_less_20_SERRF").text(((ddd.rsds.filter(x=>x<0.2).length)/ddd.rsds.length * 100).toFixed(2)+"%") 
                        $("#count_less_20_raw").text(ddd.before_rsds.filter(x=>x<0.2).length) 
                        $("#perc_less_20_raw").text(((ddd.before_rsds.filter(x=>x<0.2).length)/ddd.before_rsds.length * 100).toFixed(2)+"%") 
                        after_pca = new ML.PCA(jStat.transpose(ddd.normalized), {
                          scale: !0
                        })
                        after_pca_scores = after_pca.predict(jStat.transpose(ddd.normalized))
                        var PC1_label = "PC 1 (" + (100 * after_pca.getExplainedVariance()[0]).toFixed(2) + "%)"
                        var PC2_label = "PC 2 (" + (100 * after_pca.getExplainedVariance()[1]).toFixed(2) + "%)"
                        var PC1 = after_pca_scores.map(db => db[0])
                        var PC2 = after_pca_scores.map(db => db[1])
                        var color_by = pData.map(x=>x[sampleType_index])
                        color_by.shift()
                        var shape_by = Array(color_by.length).fill("")
                        var sample_label = pData.map(x=>x[label_index]);
                        sample_label.shift();
                        var after_score_plot_dta = score_plot(PC1, PC2, PC1_label, PC2_label, null, color_by, shape_by, ["red", "rgba(0, 0, 0, 0)"], ["circle"], ["qc", "sample"], [""], sample_label, 6, !1, !1, !1)
                        after_score_plot_dta.layout.title = "SERRF Normalized Data"
                        Plotly.newPlot("after_pca", after_score_plot_dta.data, after_score_plot_dta.layout).then(function(db) {
                          Plotly.toImage(db, {
                            format: "svg"
                          }).then(function(url) {
                            uuu = url, uuu = uuu.replace(/^data:image\/svg\+xml,/, ""), uuu = decodeURIComponent(uuu), pca_plot_url.after_score_plot = btoa(unescape(encodeURIComponent(uuu)))
                          })
                          
                        })
                        var compound_label_index = fData[0].indexOf("label")
                        compound_label = fData.map(x=>x[compound_label_index])
                        compound_label.shift();
                        result_datatable = []
                        for (var i=0; i<ddd.rsds.length;i++){
                          result_datatable.push({
                            index: i,
                            label: compound_label[i],
                            before_QC_RSD: Number(ddd.before_rsds[i].toFixed(4)),
                            after_QC_RSD: Number(ddd.rsds[i].toFixed(4))
                          })
                        } 
                        
                        
                        $("#feedback_yes").click(function() {
                          var gb = new PouchDB("https://slfan:metabolomics@serrf.fiehnlab.ucdavis.edu/db/serrf");
                          gb.get(project_id, {
                            attachments: !0
                          }).then(function(Ob) {
                            ddddd = Ob, Ob.feedback = "yes", gb.put(Ob), $("#feedback_response").text("Thank you! We are glad to hear that!"), $("#asking_feedback").css("display", "none")
                          })
                        })
                        $("#feedback_no").click(function() {
                          var gb = new PouchDB("https://slfan:metabolomics@serrf.fiehnlab.ucdavis.edu/db/serrf");
                          gb.get(project_id, {
                            attachments: !0
                          }).then(function(Ob) {
                            ddddd = Ob, Ob.feedback = "no", gb.put(Ob), $("#feedback_response").html("Sorry to hear that! <a href='https://github.com/SERRFweb/app/issues' target='_blank'>Tell us what happend, please!</a>"), $("#asking_feedback").css("display", "none")
                          })
                        })
                        
                        
                        $("#download").click(function() {
                          $("#downloadText").text("Downloading..."), $("#download").prop("disabled", !0);
                          var zip = new JSZip 
                          for (var c = 0; c < Object.keys(pca_plot_url).length; c++) {
                            zip.file(Object.keys(pca_plot_url)[c] + ".svg", Object.values(pca_plot_url)[c], {
                              base64: !0
                            });
                          }
                          
                          if ("undefined" != typeof plot_url){
                            for (var c = 0; c < plot_url.length; c++) zip.file(c + ".png", plot_url[c], {
                              base64: !0
                            });
                          }
                          
                          zip.file("SERRF RSD table.csv", Papa.unparse(result_datatable));
                          
                          result_normalized_data_object = [];
                          
                          for (var c = 0; c < ddd.normalized.length; c++) {
                            temp_normalized = ddd.normalized[c]
                            var g = {
                              label: gsub(".", "_", [compound_label[c]])[0]
                            }
                            for(var h=0;h<sample_label.length;h++){
                              g[gsub(".", "_", [sample_label[h]])[0]] = temp_normalized[h];
                            }
                            
                            result_normalized_data_object.push(g)
                          }
                          zip.file("SERRF Normalized Data.csv", Papa.unparse(result_normalized_data_object)), zip.generateAsync({
                            type: "blob"
                          }).then(function(l) {
                            var m = new Date;
                            saveAs(l, "SERRF Normalization " + m.getTime() + ".zip"), $("#downloadText").text("Download Results"), $("#download").prop("disabled", !1)
                          })
                        })
                        
                      }else{
                        console.log("Still waiting")
                      }
                    })
                  }, 5000);
                  
                  
                  
                })
              })
            })
            
          })
          
          
          
        }else{
          $("#uploadedText").html("upload failed.")
          $("#apply").css("display", "none")
        }
        
        
        
        
      }
    });
  })
  
  
  
})