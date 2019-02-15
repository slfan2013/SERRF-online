angular
    .module('blankapp').controller("pcaController", function($scope, $rootScope, Upload, $timeout, $mdToast,
                      cfpLoadingBar){
      ctrl = this;
      MathJax.Hub.Queue(["Typeset",MathJax.Hub]);

      ctrl.select_data_button_text = "Select A Dataset From Database"
      ctrl.upload_data_button_text = "Upload A Dataset"
      ctrl.use_example_data_button_text = "Use The Example Dataset"
      ctrl.submit_button_text = "Calculate"
      ctrl.download_button_text = "Download Result"
      ctrl.save_button_text = "Save Result To Database"
      ctrl.upload_data_from_input_text = "submit"
      ctrl.input_data_button_text = "Upload A Dataset By Copy & Paste"
      ctrl.load_data_from_input_show = false
      ctrl.data_source = null


      ctrl.label = 'Choose a Color'

      ctrl.shape_by_options = shape_by_options
      ctrl.scale_options = scale_options

      var parameters;
      ctrl.make_data_read_here = function(obj){
        make_data_ready(obj)
        parameters = JSON.parse(localStorage.getItem('parameters'));
        ctrl.parameters.scale = parameters.pca.scale
        // initialize all the parameter for pair_score_plot.
       ctrl.parameters.pair_score_plot = {}
       ctrl.parameters.pair_score_plot.color_by_options = delete_element_from_array(Object.keys(ooo.p[0]),'label')
       ctrl.parameters.pair_score_plot.color_by_options.push("SINGLE_COLOR")

       // pair_score_plot
       ctrl.parameters.pair_score_plot.color_by = ctrl.parameters.pair_score_plot.color_by_options.includes(parameters.pca.pair_score_plot.color_by) ? parameters.pca.pair_score_plot.color_by:"SINGLE_COLOR"
       ctrl.parameters.pair_score_plot.shape_by_options = delete_element_from_array(Object.keys(ooo.p[0]),'label')
       ctrl.parameters.pair_score_plot.shape_by_options.push("SINGLE_SHAPE")
       ctrl.parameters.pair_score_plot.shape_by = ctrl.parameters.pair_score_plot.shape_by_options.includes(parameters.pca.pair_score_plot.shape_by) ? parameters.pca.pair_score_plot.shape_by:"SINGLE_SHAPE"
       ctrl.parameters.pair_score_plot.scatter_size = parameters.pca.pair_score_plot.scatter_size

       // score plot.
       ctrl.parameters.score_plot = {}
       ctrl.parameters.score_plot.color_by_options = delete_element_from_array(Object.keys(ooo.p[0]),'label')
       ctrl.parameters.score_plot.color_by_options.push("SINGLE_COLOR")
       ctrl.parameters.score_plot.color_by = ctrl.parameters.score_plot.color_by_options.includes(parameters.pca.score_plot.color_by) ? parameters.pca.score_plot.color_by:"SINGLE_COLOR"
       ctrl.parameters.score_plot.shape_by_options = delete_element_from_array(Object.keys(ooo.p[0]),'label')
       ctrl.parameters.score_plot.shape_by_options.push("SINGLE_SHAPE")
       ctrl.parameters.score_plot.shape_by = ctrl.parameters.score_plot.shape_by_options.includes(parameters.pca.score_plot.shape_by) ? parameters.pca.score_plot.shape_by:"SINGLE_SHAPE"
       ctrl.parameters.score_plot.scatter_size = parameters.pca.score_plot.scatter_size
       ctrl.parameters.score_plot.pcx = parameters.pca.score_plot.pcx
       ctrl.parameters.score_plot.pcy = parameters.pca.score_plot.pcy
       ctrl.parameters.score_plot.add_center = parameters.pca.score_plot.add_center

       ctrl.parameters.score_plot.ellipse_color = parameters.pca.score_plot.ellipse_color
       ctrl.parameters.score_plot.ellipse_shape = parameters.pca.score_plot.ellipse_shape

       // loading plot.
       ctrl.parameters.loading_plot = {}
       ctrl.parameters.loading_plot.color_by_options = delete_element_from_array(Object.keys(ooo.f[0]),'label')
       ctrl.parameters.loading_plot.color_by_options.push("SINGLE_COLOR")
       ctrl.parameters.loading_plot.color_by = ctrl.parameters.loading_plot.color_by_options.includes(parameters.pca.loading_plot.color_by) ? parameters.pca.loading_plot.color_by:"SINGLE_COLOR"
       ctrl.parameters.loading_plot.shape_by_options = delete_element_from_array(Object.keys(ooo.f[0]),'label')
       ctrl.parameters.loading_plot.shape_by_options.push("SINGLE_SHAPE")
       ctrl.parameters.loading_plot.shape_by = ctrl.parameters.loading_plot.shape_by_options.includes(parameters.pca.loading_plot.shape_by) ? parameters.pca.loading_plot.shape_by:"SINGLE_SHAPE"
       ctrl.parameters.loading_plot.scatter_size = parameters.pca.loading_plot.scatter_size
       ctrl.parameters.loading_plot.pcx = parameters.pca.loading_plot.pcx
       ctrl.parameters.loading_plot.pcy = parameters.pca.loading_plot.pcy
       ctrl.parameters.loading_plot.add_center = parameters.pca.loading_plot.add_center
       ctrl.parameters.loading_plot.ellipse_color = parameters.pca.loading_plot.ellipse_color
       ctrl.parameters.loading_plot.ellipse_shape = parameters.pca.loading_plot.ellipse_shape



        $scope.$watch("ctrl.parameters",function(newValue, oldValue){
          parameters.pca.pair_score_plot.color_by = ctrl.parameters.pair_score_plot.color_by
          parameters.pca.pair_score_plot.shape_by = ctrl.parameters.pair_score_plot.shape_by
          parameters.pca.pair_score_plot.scatter_size = ctrl.parameters.pair_score_plot.scatter_size

          parameters.pca.score_plot.color_by = ctrl.parameters.score_plot.color_by
          parameters.pca.score_plot.shape_by = ctrl.parameters.score_plot.shape_by
          parameters.pca.score_plot.scatter_size = ctrl.parameters.score_plot.scatter_size
          parameters.pca.score_plot.pcx = ctrl.parameters.score_plot.pcx
          parameters.pca.score_plot.pcy = ctrl.parameters.score_plot.pcy
          parameters.pca.score_plot.add_center = ctrl.parameters.score_plot.add_center
          parameters.pca.score_plot.ellipse_color = ctrl.parameters.score_plot.ellipse_color
          parameters.pca.score_plot.ellipse_shape = ctrl.parameters.score_plot.ellipse_shape

          parameters.pca.loading_plot.color_by = ctrl.parameters.loading_plot.color_by
          parameters.pca.loading_plot.shape_by = ctrl.parameters.loading_plot.shape_by
          parameters.pca.loading_plot.scatter_size = ctrl.parameters.loading_plot.scatter_size
          parameters.pca.loading_plot.pcx = ctrl.parameters.loading_plot.pcx
          parameters.pca.loading_plot.pcy = ctrl.parameters.loading_plot.pcy
          parameters.pca.loading_plot.add_center = ctrl.parameters.loading_plot.add_center
          parameters.pca.loading_plot.ellipse_color = ctrl.parameters.loading_plot.ellipse_color
          parameters.pca.loading_plot.ellipse_shape = ctrl.parameters.loading_plot.ellipse_shape

          parameters.pca.scale = ctrl.parameters.scale
          localStorage.setItem('parameters', JSON.stringify(parameters));
        },true)


      }


      ctrl.upload_data_from_input = function(){
        ctrl.upload_data_from_input_text = "uploading"
        var req=ocpu.call("upload_data_from_input",{
               txt:document.getElementById("dataset_input").value
             },function(session){
               ctrl.data_source = null
               sss = session
               session.getObject(function(obj){
                 ooo = obj
                 ctrl.make_data_read_here(obj)
                 $scope.$apply()
               })
             }).done(function(){
               console.log("Data read from the textarea.")
             }).fail(function(){
               alert("Error: " + req.responseText)
             }).always(function(){
               ctrl.upload_data_from_input_text = "submit"
             })
      }

      ctrl.load_data_from_database = function(module){
        mainctrl.the_waiting_module = module
        mainctrl.toggleLeft('right',true)
      }


      ctrl.uploadFiles = function(file, errFiles) {
        ctrl.upload_data_button_text = 'uploading'
        // when user simply upload a dataset,create a temp project.
        var project_db = new PouchDB('https://tempusername:temppassword@metda.fiehnlab.ucdavis.edu/db/project');
        var time_stamp = get_time_string()
        var temp_project_id = "temp"+time_stamp
        var new_project = {
          _id:temp_project_id
        }
        project_db.put(new_project).then(function(doc){
          ctrl.f = file;
          ctrl.errFile = errFiles && errFiles[0];
          if (file) {
            console.log(file)
             var req=ocpu.call("upload_dataset",{
               path:file,
               project_id:temp_project_id
             },function(session){
               sss = session
               session.getObject(function(obj){
                 ctrl.data_source = null
                 ooo = obj
                 ctrl.make_data_read_here(obj)
                 $scope.$apply();
               })
             }).done(function(){
               $scope.$apply(function(){file.progress = 100;})
             }).fail(function(){
               alert("Error: " + req.responseText)
             }).always(function(){
               ctrl.upload_data_button_text = "Upload A Dataset"
             });

          }
        })


      }




      ctrl.submit = function(){
        ctrl.submit_button_text = "Calculating"
        cfpLoadingBar.start();
        ctrl.parameters.fun_name = "pca"
        var req = ocpu.call("call_fun",{parameters:ctrl.parameters},function(session){
          sss = session
          session.getObject(function(obj){
            oo = obj
           $scope.$apply();
          }).then(function(){
            plot_url = []
            ctrl.plot_parameters = {}

            // generate scree plot
            scree_plot_dta = scree_plot(oo.variance)
            Plotly.newPlot('scree_plot', scree_plot_dta.data, scree_plot_dta.layout).then(function(gd){
                    Plotly.toImage(gd,{format:'svg'})
                    .then(
                      function(url)
                       {
                         uuuu = url
                         //uuu = uuu.replace(/^data:image\/svg\+xml,/, '');
                         //uuu = decodeURIComponent(uuu);
                         //plot_url.scree_plot=  btoa(unescape(encodeURIComponent(uuu)))
                          var canvas = document.createElement("canvas");
                          var context = canvas.getContext("2d");
                          canvas.width = 4000;
                          canvas.height = 3000;
                          var image = new Image();
                          context.clearRect ( 0, 0, 4000, 3000 );
                          var imgsrc = 'data:image/svg+xml;base64,'+ btoa(unescape(url.replace("data:image/svg+xml,",""))); // Convert SVG string to data URL

                          var image = new Image();
                          image.onload = function() {
                              context.drawImage(image, 0, 0, 4000, 3000);
                              var img = canvas.toDataURL("image/png");
                              base64 = img.replace("data:image/png;base64,","")
                              plot_url.scree_plot = base64
                          };
                          image.src = imgsrc
                       }
                   )
                  });
            sum_variance = 0
            for(var i = 0; i<oo.variance.length;i++){
              if(sum_variance+oo.variance[i]>0.8){
                which_greater_than_80_percent = i+1
                break;
              }else{
                sum_variance = sum_variance+oo.variance[i]
              }
            }
            ctrl.scree_plot_report = "<p>The scree plot shows the fraction of total variance in the data as explained or represented by each principal component (PC).</p><p>The first two PCs explained <code>"+((oo.variance[0]+oo.variance[1])*100).toFixed(2)+"%</code> of the variance, while the rest <code>"+(oo.variance.length-2)+"</code> PCs explained the <code>"+((100-(oo.variance[0]+oo.variance[1])*100)).toFixed(2)+"%</code> variance.</p><p>A cumulative of 80% variance is achieved at the <code>"+which_greater_than_80_percent+"th</code> PC.</p>"


                 $scope.$watch("ctrl.parameters.pair_score_plot.color_by",function(newValue){
                   ctrl.parameters.pair_score_plot.color_levels = unpack(ooo.p,ctrl.parameters.pair_score_plot.color_by).filter(unique)
                 })
                 $scope.$watch("ctrl.parameters.pair_score_plot.color_levels",function(newValue){
                   ctrl.parameters.pair_score_plot.color = []
                   for(var i=0;i<ctrl.parameters.pair_score_plot.color_levels.length;i++){
                     if(ctrl.parameters.pair_score_plot.color_levels.length==1){
                       ctrl.parameters.pair_score_plot.color.push({
                         levels:ctrl.parameters.pair_score_plot.color_levels[i],
                         option:"rgba(0,0,0,1)"
                       })
                     }else{
                       ctrl.parameters.pair_score_plot.color.push({
                         levels:ctrl.parameters.pair_score_plot.color_levels[i],
                         option:color_palette.mpn65[i]
                       })
                     }

                   }
                 })

                 $scope.$watch("ctrl.parameters.pair_score_plot.shape_by",function(newValue){
                   ctrl.parameters.pair_score_plot.shape_levels = unpack(ooo.p,ctrl.parameters.pair_score_plot.shape_by).filter(unique)
                 })

                 $scope.$watch("ctrl.parameters.pair_score_plot.shape_levels",function(newValue){
                   ctrl.parameters.pair_score_plot.shape = []
                   for(var i=0;i<ctrl.parameters.pair_score_plot.shape_levels.length;i++){
                     ctrl.parameters.pair_score_plot.shape.push({
                       levels:ctrl.parameters.pair_score_plot.shape_levels[i],
                       option:shape_palette.ggplot2[i]
                     })
                   }
                 })

                 $scope.$watch("ctrl.parameters.pair_score_plot",function(newValue){
                   // generate pair score plot
                  pair_score_plot_dta = pair_score_plot(jStat.transpose(oo.scores),oo.variance, unpack(ooo.p,ctrl.parameters.pair_score_plot.color_by),unpack(ooo.p,ctrl.parameters.pair_score_plot.shape_by), unpack(ctrl.parameters.pair_score_plot.color,"option"), unpack(ctrl.parameters.pair_score_plot.shape,"option"), unpack(ctrl.parameters.pair_score_plot.color,"levels"),unpack(ctrl.parameters.pair_score_plot.shape,"levels"),unpack(ooo.p, 'label'),ctrl.parameters.pair_score_plot.scatter_size)
                  Plotly.newPlot('pair_score_plot', pair_score_plot_dta.data, pair_score_plot_dta.layout)
                  .then(function(gd){
                    Plotly.toImage(gd,{format:'svg'})
                    .then(
                      function(url)
                       {
                         uuu = url
                         /*uuu = uuu.replace(/^data:image\/svg\+xml,/, '');
                         uuu = decodeURIComponent(uuu);
                         plot_url.pair_score_plot = btoa(unescape(encodeURIComponent(uuu)))*/

                          var canvas = document.createElement("canvas");
                          var context = canvas.getContext("2d");
                          canvas.width = 3000;
                          canvas.height = 3000;
                          var image = new Image();
                          context.clearRect ( 0, 0, 3000, 3000 );
                          var imgsrc = 'data:image/svg+xml;base64,'+ btoa(unescape(url.replace("data:image/svg+xml,",""))); // Convert SVG string to data URL

                          var image = new Image();
                          image.onload = function() {
                              context.drawImage(image, 0, 0, 3000, 3000);
                              var img = canvas.toDataURL("image/png");
                              base64 = img.replace("data:image/png;base64,","")
                              plot_url.pair_score_plot = base64
                          };
                          image.src = imgsrc




                       }
                   )
                  })

                  ;
                  $("#pair_score_plot div div")[0].style.margin="0 auto"
                 },true)

                 $scope.$watch("ctrl.parameters.score_plot.color_by",function(newValue){
                   ctrl.parameters.score_plot.color_levels = unpack(ooo.p,ctrl.parameters.score_plot.color_by).filter(unique)
                 })
                 $scope.$watch("ctrl.parameters.score_plot.color_levels",function(newValue){
                   ctrl.parameters.score_plot.color = []
                   for(var i=0;i<ctrl.parameters.score_plot.color_levels.length;i++){
                     if(ctrl.parameters.score_plot.color_levels.length==1){
                       ctrl.parameters.score_plot.color.push({
                         levels:ctrl.parameters.score_plot.color_levels[i],
                         option:"rgba(0,0,0,1)"
                       })
                     }else{
                       ctrl.parameters.score_plot.color.push({
                         levels:ctrl.parameters.score_plot.color_levels[i],
                         option:color_palette.mpn65[i]
                       })
                     }

                   }
                 })


                 $scope.$watch("ctrl.parameters.score_plot.shape_by",function(newValue){
                   ctrl.parameters.score_plot.shape_levels = unpack(ooo.p,ctrl.parameters.score_plot.shape_by).filter(unique)
                 })


                 ctrl.parameters.score_plot.pcx_options = []
                 for(var i=0; i<oo.scores.length;i++){
                   ctrl.parameters.score_plot.pcx_options.push({
                     value:i,
                     text:"PC "+(i+1)
                   })
                 }
                 ctrl.parameters.score_plot.pcy_options=[]
                 for(var i=0; i<oo.scores.length;i++){
                   ctrl.parameters.score_plot.pcy_options.push({
                     value:i,
                     text:"PC "+(i+1)
                   })
                 }
                 $scope.$watch("ctrl.parameters.score_plot.shape_levels",function(newValue){
                   ctrl.parameters.score_plot.shape = []
                   for(var i=0;i<ctrl.parameters.score_plot.shape_levels.length;i++){
                     ctrl.parameters.score_plot.shape.push({
                       levels:ctrl.parameters.score_plot.shape_levels[i],
                       option:shape_palette.ggplot2[i]
                     })
                   }
                 })

                 $scope.$watch("ctrl.parameters.score_plot",function(newValue){


                   // generate score plot
                  score_plot_dta = score_plot(jStat.transpose(oo.scores)[ctrl.parameters.score_plot.pcx],jStat.transpose(oo.scores)[ ctrl.parameters.score_plot.pcy],"PC"+(Number(ctrl.parameters.score_plot.pcx)+1)+" ("+(oo.variance[ctrl.parameters.score_plot.pcx]*100).toFixed(2)+"%)", "PC"+(Number(ctrl.parameters.score_plot.pcy)+1)+" ("+(oo.variance[ctrl.parameters.score_plot.pcy]*100).toFixed(2)+"%)", oo.variance,   unpack(ooo.p,ctrl.parameters.score_plot.color_by),  unpack(ooo.p,ctrl.parameters.score_plot.shape_by), unpack(ctrl.parameters.score_plot.color,"option"), unpack(ctrl.parameters.score_plot.shape,"option"), unpack(ctrl.parameters.score_plot.color,"levels"), unpack(ctrl.parameters.score_plot.shape,"levels"), unpack(ooo.p, 'label'), ctrl.parameters.score_plot.scatter_size, ctrl.parameters.score_plot.add_center, ctrl.parameters.score_plot.ellipse_color, ctrl.parameters.score_plot.ellipse_shape)
                  Plotly.newPlot('score_plot', score_plot_dta.data, score_plot_dta.layout).then(function(gd){
                    Plotly.toImage(gd,{format:'svg'})
                    .then(
                      function(url)
                       {
                         uuu = url
                         /*uuu = uuu.replace(/^data:image\/svg\+xml,/, '');
                         uuu = decodeURIComponent(uuu);
                         plot_url.score_plot = btoa(unescape(encodeURIComponent(uuu)))*/


                          var canvas = document.createElement("canvas");
                          var context = canvas.getContext("2d");
                          canvas.width = 4000;
                          canvas.height = 3000;
                          var image = new Image();
                          context.clearRect ( 0, 0, 4000, 3000 );
                          var imgsrc = 'data:image/svg+xml;base64,'+ btoa(unescape(url.replace("data:image/svg+xml,",""))); // Convert SVG string to data URL

                          var image = new Image();
                          image.onload = function() {
                              context.drawImage(image, 0, 0, 4000, 3000);
                              var img = canvas.toDataURL("image/png");
                              base64 = img.replace("data:image/png;base64,","")
                              plot_url.score_plot = base64
                          };
                          image.src = imgsrc


                       }
                   )
                  })
                  $("#score_plot div div")[0].style.margin="0 auto"
                 },true)


                 // loading
                 $scope.$watch("ctrl.parameters.loading_plot.color_by",function(newValue){
                   ctrl.parameters.loading_plot.color_levels = unpack(ooo.f,ctrl.parameters.loading_plot.color_by).filter(unique)
                 })
                 $scope.$watch("ctrl.parameters.loading_plot.color_levels",function(newValue){
                   ctrl.parameters.loading_plot.color = []
                   for(var i=0;i<ctrl.parameters.loading_plot.color_levels.length;i++){
                     if(ctrl.parameters.loading_plot.color_levels.length==1){
                       ctrl.parameters.loading_plot.color.push({
                         levels:ctrl.parameters.loading_plot.color_levels[i],
                         option:"rgba(0,0,0,1)"
                       })
                     }else{
                       ctrl.parameters.loading_plot.color.push({
                         levels:ctrl.parameters.loading_plot.color_levels[i],
                         option:color_palette.mpn65[i]
                       })
                     }

                   }
                 })
                 /*ctrl.parameters.loading_plot.shape_by_options = delete_element_from_array(Object.keys(ooo.f[0]),'label')
                 ctrl.parameters.loading_plot.shape_by_options.push("SINGLE_SHAPE")*/


                 $scope.$watch("ctrl.parameters.loading_plot.shape_by",function(newValue){
                   ctrl.parameters.loading_plot.shape_levels = unpack(ooo.f,ctrl.parameters.loading_plot.shape_by).filter(unique)
                 })

                 ctrl.parameters.loading_plot.pcx_options = []
                 for(var i=0; i<oo.loadings.length;i++){
                   ctrl.parameters.loading_plot.pcx_options.push({
                     value:i,
                     text:"PC "+(i+1)
                   })
                 }

                 ctrl.parameters.loading_plot.pcy_options=[]
                 for(var i=0; i<oo.loadings.length;i++){
                   ctrl.parameters.loading_plot.pcy_options.push({
                     value:i,
                     text:"PC "+(i+1)
                   })
                 }

                 $scope.$watch("ctrl.parameters.loading_plot.shape_levels",function(newValue){
                   ctrl.parameters.loading_plot.shape = []
                   for(var i=0;i<ctrl.parameters.loading_plot.shape_levels.length;i++){
                     ctrl.parameters.loading_plot.shape.push({
                       levels:ctrl.parameters.loading_plot.shape_levels[i],
                       option:shape_palette.ggplot2[i]
                     })
                   }
                 })



                 $scope.$watch("ctrl.parameters.loading_plot",function(newValue){
                   // generate pair loading plot
                  loading_plot_dta = loading_plot(jStat.transpose(oo.loadings)[ctrl.parameters.loading_plot.pcx],jStat.transpose(oo.loadings)[ ctrl.parameters.loading_plot.pcy],"PC"+(Number(ctrl.parameters.loading_plot.pcx)+1)+" ("+(oo.variance[ctrl.parameters.loading_plot.pcx]*100).toFixed(2)+"%)", "PC"+(Number(ctrl.parameters.loading_plot.pcy)+1)+" ("+(oo.variance[ctrl.parameters.loading_plot.pcy]*100).toFixed(2)+"%)", oo.variance,   unpack(ooo.f,ctrl.parameters.loading_plot.color_by),  unpack(ooo.f,ctrl.parameters.loading_plot.shape_by), unpack(ctrl.parameters.loading_plot.color,"option"), unpack(ctrl.parameters.loading_plot.shape,"option"), unpack(ctrl.parameters.loading_plot.color,"levels"), unpack(ctrl.parameters.loading_plot.shape,"levels"), unpack(ooo.f, 'label'), ctrl.parameters.loading_plot.scatter_size, ctrl.parameters.loading_plot.add_center, ctrl.parameters.loading_plot.ellipse_color, ctrl.parameters.loading_plot.ellipse_shape)
                  Plotly.newPlot('loading_plot', loading_plot_dta.data, loading_plot_dta.layout).then(function(gd){
                    Plotly.toImage(gd,{format:'svg'})
                    .then(
                      function(url)
                       {
                         uuu = url
                         /*uuu = uuu.replace(/^data:image\/svg\+xml,/, '');
                         uuu = decodeURIComponent(uuu);
                         plot_url.loading_plot = btoa(unescape(encodeURIComponent(uuu)))*/

                         var canvas = document.createElement("canvas");
                          var context = canvas.getContext("2d");
                          canvas.width = 4000;
                          canvas.height = 3000;
                          var image = new Image();
                          context.clearRect ( 0, 0, 4000, 3000 );
                          var imgsrc = 'data:image/svg+xml;base64,'+ btoa(unescape(url.replace("data:image/svg+xml,",""))); // Convert SVG string to data URL

                          var image = new Image();
                          image.onload = function() {
                              context.drawImage(image, 0, 0, 4000, 3000);
                              var img = canvas.toDataURL("image/png");
                              base64 = img.replace("data:image/png;base64,","")
                              plot_url.loading_plot = base64
                          };
                          image.src = imgsrc

                       }
                   )
                  })
                  $("#loading_plot div div")[0].style.margin="0 auto"
                 },true)


            ctrl.pair_score_plot_report = "<p>The pair scores plot shows the projection of each sample on the first five principal components (PC).</p><p>The pair scores plot is useful to visualize the relationship between multple PCs and to check outliers, group seperation, etc simultaneously. When you hover each data point, it will show you the sample label of the corresponding sample in your data.</p><p>The first five PCs explained <code>"+(jStat.sum([oo.variance[0],oo.variance[1],oo.variance[2],oo.variance[3],oo.variance[4]])*100).toFixed(2)+"%</code> of the variance, while the rest <code>"+(oo.variance.length-5)+"</code> PCs explained the <code>"+((100-(jStat.sum([oo.variance[0],oo.variance[1],oo.variance[2],oo.variance[3],oo.variance[4]]))*100)).toFixed(2)+"%</code> variance.</p>"


            // generate the sample scores plot
            ctrl.score_plot_report = "<p>The PCA - Score Plot shows the projection of each sample on the <code>"+1+"st</code> and <code>"+2+"nd</code> principal component (PC). These two PCs summarized <code>"+(jStat.sum([oo.variance[0],oo.variance[1]])*100).toFixed(2)+"%</code> of total sample variance.</p><p>The score plot is useful when you would like to understand the sample-sample correlation. Points close to each other indicates a similar distribution of compounds for the corresponding samples. Point has a converse distribtion of compounds with the one at the opposite of the origin (0,0). For example, sample point (1,1) has converse distribution of compounds with sample point (-1,-1).</p>"



            // generate the loading plot
            ctrl.loading_plot_report = "<p>The PCA - Loading Plot shows the projection of each compound on the <code>"+1+"st</code> and <code>"+2+"nd</code> principal component (PC). These two PCs summarized <code>"+(jStat.sum([oo.variance[0],oo.variance[1]])*100).toFixed(2)+"%</code> of total sample variance.</p><p>The loading plot is useful when you would like to understand the compound-compound correlation. Points close to each other indicates a highly positive correlation for the corresponding compounds. Point has a negative correlation of compounds with the one at the opposite of the origin (0,0). For example, compound point (1,1) is negativelly correlated with the compound at point (-1,-1).</p>"


            // add scores and loadings labels.
            compound_label = unpack(ooo.f,'label')
            sample_label = unpack(ooo.p,'label')
            result_scores = [Array.apply(null, {length: oo.scores[0].length}).map(Number.call, Number).map(x=>x+1).map(x => "PC "+x)].concat(oo.scores)
            result_scores = result_scores.map((x,i) => i===0? ["label"].concat(result_scores[i]) : [sample_label[i-1]].concat(result_scores[i]))
            result_scores = result_scores.map((x,i) => i===0? ["index"].concat(result_scores[i]) : [i].concat(result_scores[i]))

            result_loadings = [Array.apply(null, {length: oo.loadings[0].length}).map(Number.call, Number).map(x=>x+1).map(x => "PC "+x)].concat(oo.loadings)
            result_loadings = result_loadings.map((x,i) => i===0? ["label"].concat(result_loadings[i]) : [compound_label[i-1]].concat(result_loadings[i]))
            result_loadings = result_loadings.map((x,i) => i===0? ["index"].concat(result_loadings[i]) : [i].concat(result_loadings[i]))



            cfpLoadingBar.complete();
            $scope.$apply()
          })
        }).done(function(){
          console.log("Calculation done.")
        }).fail(function(){
          alert("Error: " + req.responseText)
        }).always(function(){
          $scope.$apply(function(){ctrl.submit_button_text = "Calculate"})
        });
      }

      ctrl.download = function(){
        var zip = new JSZip();
        for(var i=0;i<Object.keys(plot_url).length;i++){
          zip.file(Object.keys(plot_url)[i]+".png", Object.values(plot_url)[i], {base64: true});
        }

        zip.file("scores.csv",Papa.unparse(result_scores))
        zip.file("loadings.csv",Papa.unparse(result_loadings))

        zip.generateAsync({type:"blob"})
        .then(function (blob) {
            saveAs(blob, "Principal Component Analysis - Plots.zip");
        });


        //download_csv(Papa.unparse(oo.result), "Principal Component Analysis - Result.csv")
      }


      ctrl.save_result = function(){

        // trying to save result. The result must be in a form of [{},{},{}], which is a folder of the tree. In one of the {}, there is a main key indicating that this is the folder node. If the main is not found, then everything will be added to the user clicked node. For all the nodes that are not folder node, must have 'saving_content' and 'content_type' for adding the attachments. Also, these nodes's parent is to be determined by the user click.
        var time_stamp = get_time_string()
    to_be_saved_parameters = _.clone(ctrl.parameters)
    to_be_saved_parameters.e = null
    to_be_saved_parameters.f = null
    to_be_saved_parameters.p = null
        to_be_saved =
        [{
          "id":"PCA"+time_stamp,
          "parent":undefined,
          "text":"PCA",
          "icon":"fa fa-folder",
          "main":true,
          "analysis_type":"pca",
          "parameters":to_be_saved_parameters
        },
        {
          "id":"scree_plot_"+time_stamp+".png",
          "parent":"PCA"+time_stamp,
          "text":"scree plot.png",
          "icon":"fa fa-file-image-o",
          "attachment_id":"scree_plot_"+time_stamp+".png",
          "saving_content":plot_url.scree_plot,
          "content_type":"image/png"
        },
        {
          "id":"pair_score_plot_"+time_stamp+".png",
          "parent":"PCA"+time_stamp,
          "text":"pair score plot.png",
          "icon":"fa fa-file-image-o",
          "attachment_id":"pair_score_plot_"+time_stamp+".png",
          "saving_content":plot_url.pair_score_plot,
          "content_type":"image/png"
        },
        {
          "id":"score_plot_"+time_stamp+".png",
          "parent":"PCA"+time_stamp,
          "text":"score plot.png",
          "icon":"fa fa-file-image-o",
          "attachment_id":"score_plot_"+time_stamp+".png",
          "saving_content":plot_url.score_plot,
          "content_type":"image/png"
        },{
          "id":"loading_plot_"+time_stamp+".png",
          "parent":"PCA"+time_stamp,
          "text":"loading plot.png",
          "icon":"fa fa-file-image-o",
          "attachment_id":"loading_plot_"+time_stamp+".png",
          "saving_content":plot_url.loading_plot,
          "content_type":"image/png"
        },{
          "id":"sample_scores"+time_stamp+".csv",
          "parent":"PCA"+time_stamp,
          "text":"sample scores.csv",
          "icon":"fa fa-file-excel-o",
          "attachment_id":"sample_scores_"+time_stamp+".csv",
          "saving_content":btoa(unescape(encodeURIComponent(Papa.unparse(result_scores)))),
          "content_type":"application/vnd.ms-excel"
        },{
          "id":"compound_loadings"+time_stamp+".csv",
          "parent":"PCA"+time_stamp,
          "text":"compound loadings.csv",
          "icon":"fa fa-file-excel-o",
          "attachment_id":"compound_loadings_"+time_stamp+".csv",
          "saving_content":btoa(unescape(encodeURIComponent(Papa.unparse(result_loadings)))),
          "content_type":"application/vnd.ms-excel"
        }]

        mainctrl.save_result_modal(to_be_saved)
      }

	})






























