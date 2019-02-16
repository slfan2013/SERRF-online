
$(document).ready(function() {
  console.log(1548435788)
  /*
              var f = new PouchDB("https://slfan:metabolomics@serrf.fiehnlab.ucdavis.edu/db/serrf");
              f.get("queue", {
                attachments: !0
              }).then(function(g) {
              
                g.queue_id = []
                
                f.put(g)
              })
              */
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
          $("#uploadedText").html("Good! No error was found. Now, reading the dataset... (The speed depends on the network)")
              
          var time = new Date;
          project_id = Math.floor(Date.now() / 1000)
          
          
          $.getJSON("https://ipapi.co/json/", function(g) {
                gg = g;
                use_ex = pData[1][3]
                console.log(project_id + " c! status: " + use_ex);
                //project_id = time.getTime(), console.log(project_id + "c! status: " + use_ex);
                var f = new PouchDB("https://slfan:metabolomics@serrf.fiehnlab.ucdavis.edu/db/serrf");
                var l = {
                  _id: project_id + "",
                  dta: results.data,
                  success: !1,
                  feedback: !1,
                  use_ex: use_ex
                };
                console.log(l)
                f.put(l).then(function() {
                  console.log("PUT")
                  $("#uploadedText").html("Congratuations! Data uploaded, ready to SERRF. Your data contains " + fData.length + " compounds, " + qc_index.length + " qcs and "+sample_index.length+" samples processed in " + Object.keys(num_qc_per_batch).length + " batches.")
                  $("#apply").css("display", "inline-block");
                  pca_plot_url = {}
                  
                  
                }).catch(function(err){
              alert("Error: " + err+". Possibly because of slow network. Please try again.")
            })
          })
          
          
          $("#apply").click(function() {
            $("#apply").prop("disabled", !0);
            "128.120.143.234" !== gg.ip && "2600:1700:e1c0:7870:ed85:c9ca:fb95:2f46" !==gg.ip && "168.150.116.196" !== gg.ip && "2600:1700:e1c0:7870:c1b7:6ecb:cbd5:6666" !==gg.ip && Email.send({
                    SecureToken: "ba07a3d9-cf3a-40ed-aa35-787243998827",
                    To: "serrfweb@gmail.com",
                    From: "fansili2013@gmail.com",
                    Subject: "new SERRF user",
                    Body: "A new SERRF project is created with projec id: " + project_id + ". IP: " + gg.ip + ". Status: " + use_ex
                    }).then(function(m){m => console.log(m + " MS.")})
                  
            // put the project_id to the queue.
            var f = new PouchDB("https://slfan:metabolomics@serrf.fiehnlab.ucdavis.edu/db/serrf");
            f.get("queue", {
              attachments: !0
            }).then(function(g) {
              queue = g
              $("#applyText").html("<span class=\"rainbow\"><i  class=\"fa fa-spinner fa-spin\" ></i>. There are "+queue.queue_id.length+" jobs ahead of you. Please be patient. If failed, an error message will pop-up.</span>");
              
              
               queue.queue_id.push(project_id)
              
               f.put(queue).then(function(){
                 
                 
                 var error_times = 0 
                 var check_result = function(){
                   console.log("checking result.")
                   
                   var f = new PouchDB("https://slfan:metabolomics@serrf.fiehnlab.ucdavis.edu/db/serrf");
                  f.get(project_id, {
                    attachments: false
                  }).then(function(doc){
                    ddd = doc
                    console.log(ddd)
                    if(ddd.failed){
                      console.log("waiting")
                      if(ddd.error_message.indexOf('maintenance')==-1){
                        clearInterval(check_project_status_interval);
                        $(".done").css("display", "inline-block")
                        $("#applyText").html("Apply SERRF normalization")
                        $("#apply").prop("disabled", !1);
                        alert("Calculation Failed. Error Message: " + ddd.error_message);
                        
                        
                        setTimeout(function()
    {
        check_result()

    }, 5000);
                        
                        return;
                      }else{
                        console.log("main PC is under maintenance.")
                        setTimeout(function()
    {
        check_result()

    }, 5000);
                      }
                    }else if(ddd.success){
                      console.log("GOOD!")
                      if(ddd.use_ex){
                        console.log("use")
                        setTimeout(function(){
                          console.log("ok")
                          $(".done").css("display", "inline-block")
                          $("#applyText").html("Apply SERRF normalization")
                          $("#apply").prop("disabled", !1);
                        },30000);
                      }else{
                        $(".done").css("display", "inline-block")
                        $("#applyText").html("Apply SERRF normalization")
                        $("#apply").prop("disabled", !1);
                      }
                      
                      
                      
                      $("#count_less_20_SERRF").text(ddd.rsds.filter(x=>x<0.2).length) 
                      $("#perc_less_20_SERRF").text(((ddd.rsds.filter(x=>x<0.2).length)/ddd.rsds.length * 100).toFixed(2)+"%") 
                      $("#count_less_20_raw").text(ddd.before_rsds.filter(x=>x<0.2).length) 
                      $("#perc_less_20_raw").text(((ddd.before_rsds.filter(x=>x<0.2).length)/ddd.before_rsds.length * 100).toFixed(2)+"%") 
                      var after_score_plot_dta = score_plot(ddd.after_pca.PC1, ddd.after_pca.PC2, ddd.after_pca.PC1_label, ddd.after_pca.PC2_label, null, ddd.after_pca.color_by, ddd.after_pca.shape_by, ["red", "rgba(0, 0, 0, 0)"], ["circle"], ["qc", "sample"], [""], ddd.before_pca.sample_label, 6, !1, !1, !1)
                      after_score_plot_dta.layout.title = "SERRF Normalized Data"
                      Plotly.newPlot("after_pca", after_score_plot_dta.data, after_score_plot_dta.layout).then(function(db) {
                        Plotly.toImage(db, {
                          format: "svg"
                        }).then(function(url) {
                          uuu = url, uuu = uuu.replace(/^data:image\/svg\+xml,/, ""), uuu = decodeURIComponent(uuu), pca_plot_url.after_score_plot = btoa(unescape(encodeURIComponent(uuu)))
                        })
                        
                      })
                      
                      
                      var before_score_plot_dta = score_plot(ddd.before_pca.PC1, ddd.before_pca.PC2, ddd.before_pca.PC1_label, ddd.before_pca.PC2_label, null, ddd.before_pca.color_by, ddd.before_pca.shape_by, ["red", "rgba(0, 0, 0, 0)"], ["circle"], ["qc", "sample"], [""], ddd.before_pca.sample_label, 6, !1, !1, !1)
                      before_score_plot_dta.layout.title = "Raw Data"
                      Plotly.newPlot("before_pca", before_score_plot_dta.data, before_score_plot_dta.layout).then(function(db) {
                        Plotly.toImage(db, {
                          format: "svg"
                        }).then(function(url){
                          uuu = url, uuu = uuu.replace(/^data:image\/svg\+xml,/, ""), uuu = decodeURIComponent(uuu), pca_plot_url.before_score_plot = btoa(unescape(encodeURIComponent(uuu)))
                        })
                        
                      })
                      
                      
                      $("#rsdraw").text((jStat.median(ddd.before_rsds)*100).toFixed(2)+"%")
                      $("#rsdSERRF").text((jStat.median(ddd.rsds)*100).toFixed(2)+"%")
                      
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
                        sample_label = ddd.sample_label
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
                        
                        
                        Papa.parse("https://serrf.fiehnlab.ucdavis.edu/db/serrf/"+project_id+"/SERRF%20normalized%20dataset.csv", {
                          download: true,
                        	complete: function(results) {
                        		
                        		
                        zip.file("SERRF Normalized Data.csv", Papa.unparse(results.data)), zip.generateAsync({
                          type: "blob"
                        }).then(function(l) {
                          var m = new Date;
                          saveAs(l, "SERRF Normalization " + m.getTime() + ".zip"), $("#downloadText").text("Download Results"), $("#download").prop("disabled", !1)
                        })
                        		
                        		
                        	}
                        });
                        
                        
                        /*result_normalized_data_object = [];
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
                        */
                        
                        
                      })
                      
                      
                      
                      
                      
                    }else{
                      setTimeout(function()
    {
        check_result()

    }, 5000);
                    }
                    
                    
                  }).catch(function (err) {
                    console.log("error: "+ err)
                    error_times++
                    if(error_times<10){
                      setTimeout(function()
    {
        check_result()

    }, 5000);
                    }else{
                      alert("Unknown Error: "+err+". Check your network. Or contact slfan at ucdavis dot edu for help.")
                    }
                    
                    
                  });
                   
                   
                 }
                 check_result();
                 
                 
               /*var check_project_status_interval = setInterval(function() {
                 console.log("Checking result.")
                 var f = new PouchDB("https://slfan:metabolomics@serrf.fiehnlab.ucdavis.edu/db/serrf");
                  f.get(project_id, {
                    attachments: false
                  }).then(function(doc){
                    ddd = doc
                    console.log(ddd.failed)
                    if(ddd.failed){
                      if(ddd.error_message.indexOf('maintenance')==-1){
                        clearInterval(check_project_status_interval);
                        $(".done").css("display", "inline-block")
                        $("#applyText").html("Apply SERRF normalization")
                        $("#apply").prop("disabled", !1);
                        alert("Calculation Failed. Error Message: " + ddd.error_message);
                        
                        return;
                      }else{
                        console.log("main PC is under maintenance.")
                      }
                    }else if(ddd.success){
                      clearInterval(check_project_status_interval);
                      $(".done").css("display", "inline-block")
                      $("#applyText").html("Apply SERRF normalization")
                      $("#apply").prop("disabled", !1);
                      $("#count_less_20_SERRF").text(ddd.rsds.filter(x=>x<0.2).length) 
                      $("#perc_less_20_SERRF").text(((ddd.rsds.filter(x=>x<0.2).length)/ddd.rsds.length * 100).toFixed(2)+"%") 
                      $("#count_less_20_raw").text(ddd.before_rsds.filter(x=>x<0.2).length) 
                      $("#perc_less_20_raw").text(((ddd.before_rsds.filter(x=>x<0.2).length)/ddd.before_rsds.length * 100).toFixed(2)+"%") 
                      
                      
                      
                      
                      
                       
                      
                      
                      
                      
                      
                      
                      
                    }else{
                      console.log("Still waiting")
                    }
                  })
                  
                  
                  
                 
               }, 5000)*/
                 
                 
                 
                 
               })
              
            }).catch(function(err){
              alert("Error: " + err+". Possibly because of slow network. Please try again.")
            })
            
            
          })
            
          
          
          
       
        };
      }
      
    })
          
          
          
    })
})