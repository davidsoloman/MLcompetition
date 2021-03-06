##-------------------------------------------------------------------------------------------------
##   Graph
##-------------------------------------------------------------------------------------------------

##DESCRIPTION:
# this code is going to create some data set and graph for the report

## USEFULL LINKS:


## GENERAL INFO:


## Expl. of the created variables/functions

## Colours.tree....... colour palette selected for all the graphs that make reference to the tree type
## Types of Tree...... bar plot with the portions of the different trees
## 3D graph........... graph that shows the 3d representation of 3 of the attributes


###List of Graphs

##plot1............... Bar plot of the number of each Type of Trees in our daya
##plot2............... Line plot with the variance capture by PCA

##-------------------------------------------------------------------------------------------------

rm(list=ls())

## LIBRARIES
if (!require("e1071")) install.packages("e1071")
if (!require("caret")) install.packages("caret")
if (!require("doParallel")) install.packages("doParallel")
if (!require("doMC")) install.packages("doMC")
if (!require("gridExtra")) install.packages("gridExtra")
if (!require("scatterplot3d")) install.packages("scatterplot3d")


##-------------------------------------------------------------------------------------------------
##   Data Files
##-------------------------------------------------------------------------------------------------

source("Code/ReadData.R") ## all variables
#PCA_Var<-read.csv("Data/tables/PCA_Variance.csv",sep=";")

##-------------------------------------------------------------------------------------------------
##   Colours
##-------------------------------------------------------------------------------------------------

Colours.tree<-c("#d53e4f","#fc8d59","#fee08b","#ffffbf","#e6f598","#99d594","#3288bd")

##-------------------------------------------------------------------------------------------------
##   Density and Boxplot Graph
##-------------------------------------------------------------------------------------------------

BoxplotData<-as.data.frame(cbind(or.training_set$elevation,rep("training",nrow(or.training_set))))
BoxplotData<-rbind(BoxplotData,cbind(or.testing_set$elevation,rep("testing",nrow(or.testing_set))))
colnames(BoxplotData)<-c("elevation","data")
BoxplotData$elevation<-as.numeric(BoxplotData$elevation)


box.plot1<-ggplot(BoxplotData,aes(factor(data),elevation))+geom_boxplot(aes(fill=factor(data)))+
  theme(axis.text.x = element_text(angle=-30),panel.background = element_rect(fill = "white"),
        panel.grid.major.x = element_line(colour = "white",linetype="dotted"),
        panel.grid.minor.x = element_line(colour = "white"),
        panel.grid.minor.y = element_line(colour = "grey"),
        panel.grid.major.y = element_line(colour = "grey"),
        axis.text =element_text(face="bold",size="10", color="black"),
        axis.title =element_text(face="bold",size="14", color="black"),
        plot.title=element_text(face="bold",size="14", color="black"),
        legend.position="none")+
  scale_fill_manual(name="colour",values=Colours.tree[c(1,7)])+
  labs(title="BoxPlot of Elevation",x="data")

DensityData<-as.data.frame(cbind(or.training_set$slope,rep("training",nrow(or.training_set))))
DensityData<-rbind(DensityData,cbind(or.testing_set$slope,rep("testing",nrow(or.testing_set))))
colnames(DensityData)<-c("slope","data")
DensityData$slope<-as.numeric(DensityData$slope)



density<-ggplot(DensityData,aes(x=slope,fill=factor(data))) + 
  geom_density(alpha=0.3)+
  scale_fill_manual(name="colour",values=Colours.tree[c(1,7)])+
  theme(axis.text.x = element_text(angle=-30),panel.background = element_rect(fill = "white"),
        panel.grid.major.x = element_line(colour = "white",linetype="dotted"),
        panel.grid.minor.x = element_line(colour = "white"),
        panel.grid.minor.y = element_line(colour = "grey"),
        panel.grid.major.y = element_line(colour = "grey"),
        axis.text =element_text(face="bold",size="10", color="black"),
        axis.title =element_text(face="bold",size="14", color="black"),
        plot.title=element_text(face="bold",size="14", color="black"))+
  scale_y_continuous(breaks=c(0.01,0.02,0.03,0.04,0.05))+
  labs(title="Density of Slope",x="data")


rm(BoxplotData)
rm(DensityData)

##Export Results:     ----- . ----- . ----- . ----- . ----- . ----- . ----- .
png(filename="Report/Graphs/densityboxplot.png",width = 1200, height = 700)
grid.newpage() # Open a new page on grid device
pushViewport(viewport(layout = grid.layout(2, 5)))
print(box.plot1, vp = viewport(layout.pos.row = 1:2, layout.pos.col = 1:2)) 
print(density, vp = viewport(layout.pos.row = 1:2, layout.pos.col = 3:5))
dev.off()
## End of Exporting   ----- . ----- . ----- . ----- . ----- . ----- . ----- .




##-------------------------------------------------------------------------------------------------
##   Type of Trees Graph
##-------------------------------------------------------------------------------------------------
library(scales)

## graph showing the portion of the trees in our training set

training_set$Cover_Type_label<-factor(training_set$Cover_Type, levels=c(1,2,3,4,5,6,7),
                                      labels=c("Spruce","Lodgepole Pine","Ponderosa Pine",
                                               "Cottonwood/Willow","Aspen","Douglas-fir","Krummholz"))





##Export Results:     ----- . ----- . ----- . ----- . ----- . ----- . ----- .
png(filename="Report/Graphs/DistributionTrees.png",width = 1200, height = 700)
ggplot(training_set, aes(x = Cover_Type_label,fill=Cover_Type_label)) + 
  geom_bar(aes(y = (..count..)/sum(..count..))) + 
  scale_fill_manual(name="colour",values=Colours.tree)+
  theme(axis.text.x = element_text(angle=-30),panel.background = element_rect(fill = "white"),
        panel.grid.major.x = element_line(colour = "white",linetype="dotted"),
        panel.grid.minor.x = element_line(colour = "white"),
        panel.grid.minor.y = element_line(colour = "grey"),
        panel.grid.major.y = element_line(colour = "grey"),
        axis.text =element_text(face="bold",size="10", color="black"),
        axis.title =element_text(face="bold",size="14", color="black"),
        plot.title=element_text(face="bold",size="14", color="black"))+
  labs(title="Distribution of Cover Type",x="Type of tree",y="percentage")+
  scale_y_continuous(labels = percent)
dev.off()

## End of Exporting   ----- . ----- . ----- . ----- . ----- . ----- . ----- .


##-------------------------------------------------------------------------------------------------
##   3D representation of some of the variables
##-------------------------------------------------------------------------------------------------

training_set$colour<-rep(0,nrow(training_set))
for(i in 1:nrow(training_set)){
  ind<-training_set$Cover_Type[i]
  training_set$colour[i]<-Colours.tree[ind]
}


#with(training_set,scatterplot3d(elevation, hor_dist_fire, hor_dist_road,
 #                               color = colour, pch = 20,angle = 70, 
  #                              col.grid = NULL, col.axis = "grey"))



#with(training_set,scatterplot3d(fire_risk, horDistHyd_ElevShift, crowFliesHyd,
 #                               color = colour, pch = 20,angle = 70, 
  #                              col.grid = NULL, col.axis = "grey"))

## Decided not to include them in the report


##-------------------------------------------------------------------------------------------------
##   Accurancy Graph
##-------------------------------------------------------------------------------------------------

accuracy<-c(0.8626,0.77418,0.87320,0.96,0.903,0.907,0.922,0.928)
Method<-c(rep("KNN",2),rep("SVM",2),rep("RF",2),rep("GBM",2))
Data<-c(rep(c("Test 10 percent","Training"),4))

Results<-data.frame(Method=Method,Accuracy=accuracy,Data=Data)



##Export Results:     ----- . ----- . ----- . ----- . ----- . ----- . ----- .
png(filename="Report/Graphs/Accuracy.png",width = 1100, height = 600)
ggplot(Results,aes(x=Accuracy,y=Method,colour=Data))+geom_point(size=5)+
  theme(panel.background = element_rect(fill = "white"),
        panel.grid.major.x = element_line(colour = "white",linetype="dotted"),
        panel.grid.minor.x = element_line(colour = "white"),
        panel.grid.minor.y = element_line(colour = "grey"),
        panel.grid.major.y = element_line(colour = "grey"),
        legend.position = "top",
        axis.text =element_text(face="bold",size="14", color="black"),
        axis.title =element_text(face="bold",size="14", color="black"),
        plot.title=element_text(face="bold",size="14", color="black"))+
  labs(title="Accuracy for Different Methods on the Training set and the 10% Testing Data on Kaggle")
dev.off()
## End of Exporting   ----- . ----- . ----- . ----- . ----- . ----- . ----- .


  
