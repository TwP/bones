# $Id$

if HAVE_SOURCE_ANNOTATION_EXTRACTOR

desc "Enumerate all annotations"
task :notes do
  SourceAnnotationExtractor.enumerate "OPTIMIZE|FIXME|TODO", :tag => true
end

namespace :notes do
  desc "Enumerate all OPTIMIZE annotations"
  task :optimize do
    SourceAnnotationExtractor.enumerate "OPTIMIZE"
  end

  desc "Enumerate all FIXME annotations"
  task :fixme do
    SourceAnnotationExtractor.enumerate "FIXME"
  end

  desc "Enumerate all TODO annotations"
  task :todo do
    SourceAnnotationExtractor.enumerate "TODO"
  end
end

end  # if HAVE_SOURCE_ANNOTATION_EXTRACTOR

# EOF
